import { createClient } from 'npm:@supabase/supabase-js@2';

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
        const serviceRoleKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');

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
            console.error('delete_account_auth_failed', {
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

        const userId = user.id;

        await deleteAvatarObjects({
            serviceClient,
            userId,
        });

        await deleteUserRows({
            serviceClient,
            userId,
        });

        const { error: deleteUserError } =
            await serviceClient.auth.admin.deleteUser(userId);

        if (deleteUserError) {
            console.error('delete_account_auth_user_failed', {
                userId,
                message: deleteUserError.message,
            });

            return jsonResponse(
                {
                    ok: false,
                    error: 'delete_auth_user_failed',
                },
                500,
            );
        }

        return jsonResponse(
            {
                ok: true,
            },
            200,
        );
    } catch (error) {
        const message = error instanceof Error ? error.message : String(error);

        console.error('delete_account_failed', {
            message,
            name: error instanceof Error ? error.name : 'UnknownError',
            stack: error instanceof Error ? error.stack : null,
        });

        return jsonResponse(
            {
                ok: false,
                error: 'delete_account_failed',
                reason: message,
            },
            500,
        );
    }
});

async function deleteAvatarObjects(args: {
    serviceClient: ReturnType<typeof createClient>;
    userId: string;
}) {
    const { serviceClient, userId } = args;

    const { data: objects, error: listError } = await serviceClient.storage
        .from('avatars')
        .list(userId, {
            limit: 100,
            offset: 0,
            sortBy: {
                column: 'name',
                order: 'asc',
            },
        });

    if (listError) {
        console.error('delete_account_avatar_list_failed', {
            userId,
            message: listError.message,
        });

        throw new Error('avatar_list_failed');
    }

    if (!objects || objects.length === 0) return;

    const paths = objects
        .map((item) => `${userId}/${item.name}`)
        .filter((path) => path.trim().length > 0);

    if (paths.length === 0) return;

    const { error: removeError } = await serviceClient.storage
        .from('avatars')
        .remove(paths);

    if (removeError) {
        console.error('delete_account_avatar_remove_failed', {
            userId,
            message: removeError.message,
        });

        throw new Error('avatar_remove_failed');
    }
}

async function deleteUserRows(args: {
    serviceClient: ReturnType<typeof createClient>;
    userId: string;
}) {
    const { serviceClient, userId } = args;

    const orderedTables = [
        'analytics_events',
        're_engagement_records',
        'quick_fix_events',
        'saved_sessions',

        'session_step_events',
        'session_state_snapshots',
        'session_feedback',
        'session_runs',

        'purchase_verifications',
        'purchase_transactions',
        'user_entitlements',

        'user_preferences',
        'profiles',
    ];

    for (const table of orderedTables) {
        const { error } = await serviceClient
            .from(table)
            .delete()
            .eq('user_id', userId);

        if (error) {
            console.error('delete_account_table_failed', {
                userId,
                table,
                message: error.message,
            });

            throw new Error(`delete_failed_${table}`);
        }
    }
}

function extractBearerToken(value: string): string {
    const trimmed = value.trim();

    if (!trimmed) return '';

    const match = trimmed.match(/^Bearer\s+(.+)$/i);

    if (!match?.[1]) return '';

    return match[1].trim();
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