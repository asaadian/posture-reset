# Public activity aggregates for Desk Workout

**Status: APPLIED to Posture Reset Supabase on 2026-10-31** with explicit user authorization.

These SQL functions return only public aggregate counts. They do not return user IDs,
email addresses, raw activity records, or session timestamps. The client
queries `public_top_sessions` and `public_program_join_counts`. 

The live app uses these functions for aggregate-only statistics. Counts remain truthful; compact notation appears only at larger magnitudes.

```sql
BEGIN;

CREATE OR REPLACE FUNCTION public.public_top_sessions()
RETURNS TABLE (session_id text, run_count bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT sr.session_id, count(*)::bigint
  FROM public.session_runs AS sr
  JOIN public.session_templates AS st ON st.id = sr.session_id
  WHERE sr.status = 'completed' AND st.is_active = true
  GROUP BY sr.session_id
  ORDER BY count(*) DESC, sr.session_id ASC
  LIMIT 10;
$$;

CREATE OR REPLACE FUNCTION public.public_program_join_counts()
RETURNS TABLE (program_id text, joined_count bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT p.id, count(DISTINCT progress.user_id)::bigint
  FROM public.recovery_programs AS p
  LEFT JOIN public.user_recovery_program_progress AS progress
    ON progress.program_id = p.id
  GROUP BY p.id;
$$;

REVOKE ALL ON FUNCTION public.public_top_sessions() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.public_program_join_counts() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_top_sessions() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.public_program_join_counts() TO anon, authenticated;

COMMIT;
```

Before applying, verify the table policies, execution plan, and whether a
minimum distinct-user threshold is needed before public display. In this
project's current dataset, some sessions have been completed by just one user.
