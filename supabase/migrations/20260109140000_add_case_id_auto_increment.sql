-- Create sequence for case ID reference numbers
CREATE SEQUENCE IF NOT EXISTS case_id_ref_seq START 1;
-- Create function to generate case ID based on FVS-PROTOCOL#-ORIGIN-REF format
CREATE OR REPLACE FUNCTION generate_case_id(
    origin_param TEXT,
    context_param TEXT
)
RETURNS TEXT AS $$
DECLARE
    origin_abbr TEXT;
    protocol_number TEXT := '001';
    ref_number TEXT;
    case_id TEXT;
BEGIN
    -- Map origin to abbreviation
    origin_abbr := CASE origin_param
        WHEN 'IC/NGA' THEN 'IC'
        WHEN 'DoD/DIA' THEN 'DOD'
        WHEN 'USN' THEN 'USN'
        WHEN 'USAF' THEN 'USAF'
        WHEN 'NASA' THEN 'NASA'
        WHEN 'Congressional' THEN 'CONG'
        WHEN 'Private Sector' THEN 'PRIV'
        WHEN 'Academic' THEN 'ACAD'
        WHEN 'Other' THEN 'OTH'
        ELSE 'UNK'
    END;

    -- Get next reference number (zero-padded to 4 digits)
    ref_number := LPAD(nextval('case_id_ref_seq')::TEXT, 4, '0');

    -- Construct case ID: FVS-PROTOCOL#-ORIGIN-REF
    case_id := 'FVS-' || protocol_number || '-' || origin_abbr || '-' || ref_number;

    RETURN case_id;
END;
$$ LANGUAGE plpgsql;
-- Create trigger function to auto-generate case_id before insert
CREATE OR REPLACE FUNCTION auto_generate_case_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate if case_id is NULL or empty
    IF NEW.case_id IS NULL OR NEW.case_id = '' THEN
        -- Generate case_id based on origin and context
        NEW.case_id := generate_case_id(NEW.origin, NEW.context);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Create trigger on target_submissions table
DROP TRIGGER IF EXISTS trigger_auto_generate_case_id ON target_submissions;
CREATE TRIGGER trigger_auto_generate_case_id
    BEFORE INSERT ON target_submissions
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_case_id();
-- Comment
COMMENT ON FUNCTION generate_case_id IS 'Generates case ID in format FVS-PROTOCOL#-ORIGIN-REF (e.g., FVS-001-IC-0001)';
COMMENT ON FUNCTION auto_generate_case_id IS 'Trigger function to auto-generate case_id for target submissions';
