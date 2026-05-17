-- V3: This script synchronizes the sequences for all tables in the public schema
-- that have an 'id' column. This is useful after manually inserting data with
-- explicit IDs to ensure that the next auto-generated ID is correct.

DO $$
DECLARE
    rec RECORD;
    seq_name TEXT;
BEGIN
    -- Loop through all tables in the public schema that have an 'id' column.
    FOR rec IN (
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND column_name = 'id'
    ) LOOP
        -- Get the name of the sequence for the 'id' column.
        seq_name := pg_get_serial_sequence('"' || rec.table_name || '"', 'id');

        -- If a sequence exists, update it to the current maximum 'id' value.
        IF seq_name IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(''%s'', COALESCE((SELECT MAX(id) FROM %I), 1), (SELECT MAX(id) IS NOT NULL FROM %I));',
                seq_name, rec.table_name, rec.table_name
            );
            RAISE NOTICE 'Synchronized sequence % for table %', seq_name, rec.table_name;
        END IF;
    END LOOP;
END $$;
