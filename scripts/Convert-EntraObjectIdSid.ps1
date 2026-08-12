<#
.SYNOPSIS
    Converts between Microsoft Entra Object IDs (GUIDs) and S-1-12-1 SIDs.

.DESCRIPTION
    This script performs a local, deterministic format conversion. It does not
    connect to Microsoft Graph and does not verify whether the object exists.

.NOTES
    The Object ID to SID method follows the same byte conversion pattern used
    in Microsoft's documented PowerShell example.
#>

Set-StrictMode -Version Latest

function Convert-EntraObjectIdToSid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$ObjectId
    )

    process {
        try {
            $guid = [Guid]::Parse($ObjectId)
            $values = [UInt32[]]::new(4)
            $bytes = $guid.ToByteArray()
            [Buffer]::BlockCopy($bytes, 0, $values, 0, 16)

            "S-1-12-1-{0}-{1}-{2}-{3}" -f $values
        }
        catch {
            throw "Invalid Microsoft Entra Object ID '$ObjectId'. $($_.Exception.Message)"
        }
    }
}

function Convert-EntraSidToObjectId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Sid
    )

    process {
        $parts = $Sid.Trim() -split '-'
        if ($parts.Count -ne 8 -or ($parts[0..3] -join '-').ToUpperInvariant() -ne 'S-1-12-1') {
            throw "Invalid SID '$Sid'. Expected S-1-12-1-x-x-x-x."
        }

        $values = [UInt32[]]::new(4)
        for ($index = 0; $index -lt 4; $index++) {
            $parsedValue = [UInt32]0
            if (-not [UInt32]::TryParse($parts[$index + 4], [ref]$parsedValue)) {
                throw "Invalid SID sub-authority '$($parts[$index + 4])'. Expected an unsigned 32-bit integer."
            }
            $values[$index] = $parsedValue
        }

        $bytes = [Byte[]]::new(16)
        [Buffer]::BlockCopy($values, 0, $bytes, 0, 16)
        ([Guid]::new($bytes)).Guid
    }
}

<#
Examples:

Convert-EntraObjectIdToSid -ObjectId '73d664e4-0886-4a73-9731-8146e010541d'
# S-1-12-1-1943430372-1249052806-1182871959-492048608

Convert-EntraSidToObjectId -Sid 'S-1-12-1-1943430372-1249052806-1182871959-492048608'
# 73d664e4-0886-4a73-9731-8146e010541d
#>
