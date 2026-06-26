# Setup CRM Foundation for GHL Sub-Account
# Creates: Custom fields, tags, and sales pipeline (idempotent)
# Usage: ./setup-crm-foundation.ps1 -LocationId "TCahcPK9X1pptNjBJxP3" -ApiKey "pit-xxx"
# Or: ./setup-crm-foundation.ps1 (reads from env: GHL_ADKINS_LOCATION_ID, GHL_ADKINS_API_KEY)

param(
    [string]$LocationId,
    [string]$ApiKey,
    [string]$Verbose = $false
)

# Read from environment if not provided
if (-not $LocationId) {
    $LocationId = $env:GHL_ADKINS_LOCATION_ID
}
if (-not $ApiKey) {
    $ApiKey = $env:GHL_ADKINS_API_KEY
}

if (-not $LocationId -or -not $ApiKey) {
    Write-Error "LocationId and ApiKey required. Provide as parameters or set GHL_ADKINS_LOCATION_ID / GHL_ADKINS_API_KEY env vars"
    exit 1
}

$BaseUrl = "https://services.leadconnectorhq.com/v1"
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

Write-Host "=== GHL CRM Foundation Setup ===" -ForegroundColor Green
Write-Host "Location ID: $LocationId"
Write-Host ""

# ===== 1. CUSTOM FIELDS =====
Write-Host "[CUSTOM FIELDS]" -ForegroundColor Cyan

$CustomFields = @(
    @{
        "name" = "instrument"
        "type" = "select"
        "value" = "instrument"
        "placeholder" = "Select instrument"
        "options" = @("Piano", "Guitar", "Voice", "Drums", "Violin", "Other") | ConvertTo-Json -AsArray
    },
    @{
        "name" = "student_age"
        "type" = "number"
        "value" = "student_age"
        "placeholder" = "Age"
    },
    @{
        "name" = "skill_level"
        "type" = "select"
        "value" = "skill_level"
        "placeholder" = "Select skill level"
        "options" = @("Beginner", "Intermediate", "Advanced") | ConvertTo-Json -AsArray
    },
    @{
        "name" = "preferred_times"
        "type" = "textarea"
        "value" = "preferred_times"
        "placeholder" = "e.g., Weekday evenings, Saturday mornings"
    },
    @{
        "name" = "lead_source"
        "type" = "text"
        "value" = "lead_source"
        "placeholder" = "How did they find us?"
    }
)

# Fetch existing fields
try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/locations/$LocationId/customFields" -Headers $Headers -Method Get
    $ExistingFields = $Response.customFields
    Write-Host "[OK] Fetched existing fields ($($ExistingFields.Count) found)"
} catch {
    Write-Host "[WARN] Could not fetch existing fields (new location?): $($_.Exception.Message)"
    $ExistingFields = @()
}

# Create missing fields
foreach ($Field in $CustomFields) {
    $Exists = $ExistingFields | Where-Object { $_.value -eq $Field.value }

    if ($Exists) {
        Write-Host "  [OK] '$($Field.name)' already exists"
    } else {
        try {
            $Body = @{
                "fieldKey" = $Field.value
                "displayName" = $Field.name
                "dataType" = $Field.type
                "placeholder" = $Field.placeholder
            } | ConvertTo-Json

            if ($Field.options) {
                $Body = @{
                    "fieldKey" = $Field.value
                    "displayName" = $Field.name
                    "dataType" = $Field.type
                    "placeholder" = $Field.placeholder
                    "picklist" = $Field.options
                } | ConvertTo-Json
            }

            $Result = Invoke-RestMethod -Uri "$BaseUrl/locations/$LocationId/customFields" -Headers $Headers -Method Post -Body $Body
            Write-Host "  [OK] Created '$($Field.name)'"
        } catch {
            Write-Host "  [FAIL] Failed to create '$($Field.name)': $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# ===== 2. TAGS =====
Write-Host "[TAGS]" -ForegroundColor Cyan

$Tags = @("trial-requested", "trial-booked", "trial-completed", "enrolled", "lost", "nurture")

# Fetch existing tags (Note: GHL may not have a direct list tags endpoint, we'll create with duplicate-check)
foreach ($Tag in $Tags) {
    try {
        # Try to create the tag - GHL typically ignores if it exists
        $Body = @{
            "tagName" = $Tag
        } | ConvertTo-Json

        $Result = Invoke-RestMethod -Uri "$BaseUrl/locations/$LocationId/tags" -Headers $Headers -Method Post -Body $Body
        Write-Host "  [OK] Tag '$Tag' created/exists"
    } catch {
        # If it's a 400/409 (conflict), the tag likely exists; other errors are real problems
        if ($_.Exception.Response.StatusCode -eq 409 -or $_.Exception.Response.StatusCode -eq 400) {
            Write-Host "  [OK] Tag '$Tag' already exists"
        } else {
            Write-Host "  [WARN] Tag '$Tag': $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# ===== 3. PIPELINE =====
Write-Host "[PIPELINE]" -ForegroundColor Cyan

$PipelineName = "Trial to Enrollment"
$Stages = @(
    @{ "name" = "New Lead"; "value" = "new_lead" },
    @{ "name" = "Contacted"; "value" = "contacted" },
    @{ "name" = "Trial Booked"; "value" = "trial_booked" },
    @{ "name" = "Trial Completed"; "value" = "trial_completed" },
    @{ "name" = "Enrolled"; "value" = "enrolled" }
)

# Fetch existing pipelines
try {
    $Response = Invoke-RestMethod -Uri "$BaseUrl/opportunities/pipelines" -Headers $Headers -Method Get
    $ExistingPipeline = $Response.pipelines | Where-Object { $_.name -eq $PipelineName }

    if ($ExistingPipeline) {
        Write-Host "[OK] Pipeline '$PipelineName' already exists (ID: $($ExistingPipeline.id))"
    } else {
        # Create the pipeline
        $Body = @{
            "name" = $PipelineName
            "stages" = $Stages | ForEach-Object { @{ "name" = $_.name } }
        } | ConvertTo-Json -Depth 10

        $Result = Invoke-RestMethod -Uri "$BaseUrl/opportunities/pipelines" -Headers $Headers -Method Post -Body $Body
        Write-Host "[OK] Created pipeline '$PipelineName' (ID: $($Result.id))"
    }
} catch {
    Write-Host "[FAIL] Pipeline creation/fetch failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# ===== VERIFICATION =====
Write-Host "[VERIFICATION]" -ForegroundColor Cyan

try {
    $CustomFieldsCheck = Invoke-RestMethod -Uri "$BaseUrl/locations/$LocationId/customFields" -Headers $Headers -Method Get
    Write-Host "[OK] Custom Fields: $($CustomFieldsCheck.customFields.Count) total"
    $CustomFieldsCheck.customFields | ForEach-Object { Write-Host "    - $($_.displayName)" }
} catch {
    Write-Host "[WARN] Could not verify custom fields"
}

try {
    $PipelinesCheck = Invoke-RestMethod -Uri "$BaseUrl/opportunities/pipelines" -Headers $Headers -Method Get
    $TrialPipeline = $PipelinesCheck.pipelines | Where-Object { $_.name -eq $PipelineName }
    if ($TrialPipeline) {
        Write-Host "[OK] Pipeline '$PipelineName':"
        $TrialPipeline.stages | ForEach-Object { Write-Host "    - $($_.name)" }
    }
} catch {
    Write-Host "[WARN] Could not verify pipelines"
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
