// supabase/functions/reset_app_data/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type DeleteTarget = {
  table: string;
  column: string;
};

const deleteTargets: DeleteTarget[] = [
  { table: 'session_step_events', column: 'user_id' },
  { table: 'session_state_snapshots', column: 'user_id' },
  { table: 'session_feedback', column: 'user_id' },
  { table: 'quick_fix_events', column: 'user_id' },
  { table: 'session_runs', column: 'user_id' },
  { table: 'saved_sessions', column: 'user_id' },

  { table: 'recovery_program_day_progress', column: 'user_id' },
  { table: 'recovery_program_progress', column: 'user_id' },
  { table: 'program_day_progress', column: 'user_id' },
  { table: 'program_progress', column: 'user_id' },

  { table: 'user_program_day_progress', column: 'user_id' },
  { table: 'user_program_progress', column: 'user_id' },
  { table: 'user_recovery_program_day_progress', column: 'user_id' },
  { table: 'user_recovery_program_progress', column: 'user_id' },
  { table: 'active_programs', column: 'user_id' },
  { table: 'active_recovery_programs', column: 'user_id' },
  { table: 'program_enrollments', column: 'user_id' },
  { table: 'user_program_enrollments', column: 'user_id' },

  { table: 're_engagement_records', column: 'user_id' },
  { table: 'user_preferences', column: 'user_id' },
  { table: 'profiles', column: 'id' },
];

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

function isSkippableSchemaError(error: unknown) {
  if (!error || typeof error !== 'object') return false;

  const value = error as { code?: string; message?: string };
  const code = value.code ?? '';
  const message = value.message ?? '';

  return (
    code === '42P01' || // undefined table
    code === '42703' || // undefined column
    code === 'PGRST204' ||
    message.includes('does not exist') ||
    message.includes('Could not find the table') ||
    message.includes('Could not find') && message.includes('column')
  );
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ ok: false, error: 'method_not_allowed' }, 405);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return jsonResponse(
      {
        ok: false,
        error: 'missing_supabase_environment',
        hasSupabaseUrl: Boolean(supabaseUrl),
        hasAnonKey: Boolean(anonKey),
        hasServiceRoleKey: Boolean(serviceRoleKey),
      },
      500,
    );
  }

  const authHeader = req.headers.get('Authorization') ?? '';

  if (!authHeader.startsWith('Bearer ')) {
    return jsonResponse({ ok: false, error: 'missing_authorization' }, 401);
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });

  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();

  if (userError || !user) {
    return jsonResponse(
      {
        ok: false,
        error: 'invalid_user_token',
        message: userError?.message,
      },
      401,
    );
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  const deleted: string[] = [];
  const skipped: string[] = [];

  for (const target of deleteTargets) {
    const { error } = await adminClient
      .from(target.table)
      .delete()
      .eq(target.column, user.id);

    if (error) {
      if (isSkippableSchemaError(error)) {
        skipped.push(`${target.table}.${target.column}`);
        continue;
      }

      console.error('reset_app_data_failed', {
        table: target.table,
        column: target.column,
        code: error.code,
        message: error.message,
      });

      return jsonResponse(
        {
          ok: false,
          error: 'delete_failed',
          table: target.table,
          column: target.column,
          code: error.code,
          message: error.message,
        },
        500,
      );
    }

    deleted.push(`${target.table}.${target.column}`);
  }

  return jsonResponse({
    ok: true,
    userId: user.id,
    deleted,
    skipped,
  });
});
