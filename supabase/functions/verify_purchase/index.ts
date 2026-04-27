
import { createClient } from 'npm:@supabase/supabase-js@2';

type VerifyPurchaseRequest = {
  platform: 'android';
  productId: string;
  purchaseToken: string;
};

type GoogleProductPurchase = {
  kind?: string;
  purchaseTimeMillis?: string;
  purchaseState?: number;
  consumptionState?: number;
  developerPayload?: string;
  orderId?: string;
  purchaseType?: number;
  acknowledgementState?: number;
  purchaseToken?: string;
  productId?: string;
  quantity?: number;
  obfuscatedExternalAccountId?: string;
  obfuscatedExternalProfileId?: string;
  regionCode?: string;
};

const corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'POST, OPTIONS',
  'access-control-allow-headers':
    'authorization, x-client-info, apikey, content-type',
};

const jsonHeaders = {
  ...corsHeaders,
  'content-type': 'application/json; charset=utf-8',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }

  if (req.method !== 'POST') {
    return jsonResponse(
      {
        ok: false,
        error: 'method_not_allowed',
      },
      405,
    );
  }

  try {
    const supabaseUrl = requiredEnv('SUPABASE_URL');
    const anonKey = requiredEnv('SUPABASE_ANON_KEY');
    const serviceRoleKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');

    const googlePackageName = requiredEnv('GOOGLE_PLAY_PACKAGE_NAME');
    const coreProductId = requiredEnv('GOOGLE_PLAY_CORE_PRODUCT_ID');

    const authHeader =
      req.headers.get('authorization') ??
      req.headers.get('Authorization') ??
      '';

    const jwt = extractBearerToken(authHeader);

    if (!jwt) {
      return jsonResponse(
        {
          ok: false,
          error: 'missing_authorization_header',
        },
        401,
      );
    }

    const serviceClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        persistSession: false,
      },
    });

    const {
      data: { user },
      error: userError,
    } = await serviceClient.auth.getUser(jwt);

    if (userError || !user) {
      console.error('verify_purchase_auth_failed', {
        hasJwt: jwt.length > 0,
        userError: userError?.message ?? null,
      });

      return jsonResponse(
        {
          ok: false,
          error: 'not_authenticated',
        },
        401,
      );
    }

    const body = (await req.json().catch(() => null)) as
      | Partial<VerifyPurchaseRequest>
      | null;

    if (!body || body.platform !== 'android') {
      return jsonResponse(
        {
          ok: false,
          error: 'unsupported_platform',
        },
        400,
      );
    }

    const productId = cleanString(body.productId);
    const purchaseToken = cleanString(body.purchaseToken);

    if (!productId || !purchaseToken) {
      return jsonResponse(
        {
          ok: false,
          error: 'missing_purchase_payload',
        },
        400,
      );
    }

    if (productId !== coreProductId) {
      return jsonResponse(
        {
          ok: false,
          error: 'invalid_product_id',
        },
        403,
      );
    }

    const googleAccessToken = await getGoogleAccessToken();

    const googlePurchase = await verifyGooglePlayProductPurchase({
      accessToken: googleAccessToken,
      packageName: googlePackageName,
      productId,
      purchaseToken,
    });

    if (googlePurchase.purchaseState !== 0) {
      await recordRejectedPurchase({
        serviceClient,
        userId: user.id,
        productId,
        purchaseToken,
        googlePurchase,
        reason: 'purchase_not_completed',
      });

      return jsonResponse(
        {
          ok: false,
          error: 'purchase_not_completed',
          purchaseState: googlePurchase.purchaseState,
        },
        403,
      );
    }

    if (
      googlePurchase.productId !== undefined &&
      googlePurchase.productId !== productId
    ) {
      await recordRejectedPurchase({
        serviceClient,
        userId: user.id,
        productId,
        purchaseToken,
        googlePurchase,
        reason: 'store_product_mismatch',
      });

      return jsonResponse(
        {
          ok: false,
          error: 'store_product_mismatch',
        },
        403,
      );
    }

    const tokenHash = await sha256Hex(purchaseToken);

    const { data: existingTransaction, error: existingError } =
      await serviceClient
        .from('purchase_transactions')
        .select('id,user_id,status')
        .eq('platform', 'android')
        .eq('purchase_token_hash', tokenHash)
        .maybeSingle();

    if (existingError) {
      throw existingError;
    }

    if (
      existingTransaction &&
      existingTransaction.user_id &&
      existingTransaction.user_id !== user.id
    ) {
      return jsonResponse(
        {
          ok: false,
          error: 'purchase_token_already_used',
        },
        409,
      );
    }

    let acknowledgementResult: 'already_acknowledged' | 'acknowledged' =
      'already_acknowledged';

    if (googlePurchase.acknowledgementState !== 1) {
      await acknowledgeGooglePlayProductPurchase({
        accessToken: googleAccessToken,
        packageName: googlePackageName,
        productId,
        purchaseToken,
      });

      acknowledgementResult = 'acknowledged';
    }

    const nowIso = new Date().toISOString();

    const transactionPayload = {
      user_id: user.id,
      platform: 'android',
      store: 'google_play',
      product_id: productId,
      entitlement_key: 'core_access',
      purchase_token_hash: tokenHash,
      store_transaction_id: googlePurchase.orderId ?? null,
      status: 'granted',
      verified_at: nowIso,
      granted_at: nowIso,
      raw_store_response: googlePurchase,
      metadata: {
        google_package_name: googlePackageName,
        acknowledgement_state: googlePurchase.acknowledgementState ?? null,
        acknowledgement_result: acknowledgementResult,
        purchase_type: googlePurchase.purchaseType ?? null,
        region_code: googlePurchase.regionCode ?? null,
      },
    };

    const { error: transactionError } = await serviceClient
      .from('purchase_transactions')
      .upsert(transactionPayload, {
        onConflict: 'platform,purchase_token_hash',
      });

    if (transactionError) {
      throw transactionError;
    }

    const { data: entitlement, error: entitlementError } = await serviceClient
      .from('user_entitlements')
      .upsert(
        {
          user_id: user.id,
          entitlement_key: 'core_access',
          status: 'active',
          purchase_source: 'google_play',
          product_id: productId,
          granted_at: nowIso,
          expires_at: null,
          metadata: {
            source: 'verify_purchase',
            platform: 'android',
            store: 'google_play',
            product_id: productId,
            order_id: googlePurchase.orderId ?? null,
            purchase_token_hash: tokenHash,
            acknowledgement_result: acknowledgementResult,
          },
        },
        {
          onConflict: 'user_id,entitlement_key',
        },
      )
      .select('entitlement_key,status,purchase_source,product_id,granted_at')
      .single();

    if (entitlementError) {
      throw entitlementError;
    }

    return jsonResponse(
      {
        ok: true,
        entitlement,
      },
      200,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);

    console.error('verify_purchase_failed', {
      message,
      name: error instanceof Error ? error.name : 'UnknownError',
      stack: error instanceof Error ? error.stack : null,
    });

    return jsonResponse(
      {
        ok: false,
        error: 'verify_purchase_failed',
        reason: message,
      },
      500,
    );
  }
});

async function recordRejectedPurchase(args: {
  serviceClient: ReturnType<typeof createClient>;
  userId: string;
  productId: string;
  purchaseToken: string;
  googlePurchase: GoogleProductPurchase;
  reason: string;
}) {
  const tokenHash = await sha256Hex(args.purchaseToken);

  await args.serviceClient.from('purchase_transactions').upsert(
    {
      user_id: args.userId,
      platform: 'android',
      store: 'google_play',
      product_id: args.productId,
      entitlement_key: 'core_access',
      purchase_token_hash: tokenHash,
      store_transaction_id: args.googlePurchase.orderId ?? null,
      status: 'rejected',
      verified_at: new Date().toISOString(),
      raw_store_response: args.googlePurchase,
      metadata: {
        rejection_reason: args.reason,
      },
    },
    {
      onConflict: 'platform,purchase_token_hash',
    },
  );
}

async function verifyGooglePlayProductPurchase(args: {
  accessToken: string;
  packageName: string;
  productId: string;
  purchaseToken: string;
}): Promise<GoogleProductPurchase> {
  const packageName = encodeURIComponent(args.packageName);
  const productId = encodeURIComponent(args.productId);
  const token = encodeURIComponent(args.purchaseToken);

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}` +
    `/purchases/products/${productId}/tokens/${token}`;

  const response = await fetch(url, {
    method: 'GET',
    headers: {
      authorization: `Bearer ${args.accessToken}`,
      accept: 'application/json',
    },
  });

  const body = await response.json().catch(() => null);

  if (!response.ok) {
    console.error('google_play_verify_failed', {
      status: response.status,
      body,
    });

    throw new Error('google_play_verify_failed');
  }

  return body as GoogleProductPurchase;
}

async function acknowledgeGooglePlayProductPurchase(args: {
  accessToken: string;
  packageName: string;
  productId: string;
  purchaseToken: string;
}): Promise<void> {
  const packageName = encodeURIComponent(args.packageName);
  const productId = encodeURIComponent(args.productId);
  const token = encodeURIComponent(args.purchaseToken);

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}` +
    `/purchases/products/${productId}/tokens/${token}:acknowledge`;

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${args.accessToken}`,
      accept: 'application/json',
      'content-type': 'application/json',
    },
    body: JSON.stringify({}),
  });

  const body = await response.json().catch(() => null);

  if (!response.ok) {
    console.error('google_play_acknowledge_failed', {
      status: response.status,
      body,
    });

    throw new Error('google_play_acknowledge_failed');
  }
}

async function getGoogleAccessToken(): Promise<string> {
  const clientEmail = requiredEnv('GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL');
  const privateKey = normalizePrivateKey(
    requiredEnv('GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'),
  );

  const now = Math.floor(Date.now() / 1000);

  const header = {
    alg: 'RS256',
    typ: 'JWT',
  };

  const claimSet = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/androidpublisher',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const unsignedJwt = `${base64UrlJson(header)}.${base64UrlJson(claimSet)}`;
  const signature = await signRs256(unsignedJwt, privateKey);
  const assertion = `${unsignedJwt}.${signature}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'content-type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });

  const body = await response.json().catch(() => null);

  if (!response.ok || !body?.access_token) {
    console.error('google_oauth_failed', {
      status: response.status,
      body,
    });

    throw new Error('google_oauth_failed');
  }

  return body.access_token as string;
}

async function signRs256(input: string, privateKeyPem: string): Promise<string> {
  const binaryDer = pemToArrayBuffer(privateKeyPem);

  const key = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(input),
  );

  return base64UrlBytes(new Uint8Array(signature));
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');

  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes.buffer;
}

function base64UrlJson(value: unknown): string {
  return base64UrlBytes(new TextEncoder().encode(JSON.stringify(value)));
}

function base64UrlBytes(bytes: Uint8Array): string {
  let binary = '';

  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }

  return btoa(binary)
    .replaceAll('+', '-')
    .replaceAll('/', '_')
    .replaceAll('=', '');
}

async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(value),
  );

  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join('');
}

function normalizePrivateKey(value: string): string {
  return value.replaceAll('\\n', '\n');
}

function extractBearerToken(value: string): string {
  const trimmed = value.trim();

  if (!trimmed) {
    return '';
  }

  const match = trimmed.match(/^Bearer\s+(.+)$/i);

  if (!match?.[1]) {
    return '';
  }

  return match[1].trim();
}

function cleanString(value: unknown): string {
  if (typeof value !== 'string') return '';
  return value.trim();
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value || value.trim().length === 0) {
    throw new Error(`missing_env_${name}`);
  }

  return value;
}

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: jsonHeaders,
  });
}