@{
    # PowerShell Script Analyzer Settings
    # https://github.com/PowerShell/PSScriptAnalyzer

    # Enable all default rules
    IncludeDefaultRules = $true

    # Severity levels: Error, Warning, Information
    Severity = @('Error', 'Warning', 'Information')

    # Rules to exclude (customize as needed)
    ExcludeRules = @(
        # Uncomment rules you want to exclude
        # 'PSAvoidUsingWriteHost',  # Allow Write-Host for console output
        # 'PSUseShouldProcessForStateChangingFunctions'
    )

    # Custom rule configurations
    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
            CheckInnerBrace = $true
            CheckPipe = $true
            CheckParameter = $false
        }

        PSAlignAssignmentStatement = @{
            Enable = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }

        PSAvoidUsingCmdletAliases = @{
            Enable = $true
            Whitelist = @()
        }

        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $false
            BlockComment = $true
            VSCodeSnippetCorrection = $true
            Placement = 'before'
        }

        PSReservedCmdletChar = @{
            Enable = $true
        }

        PSReservedParams = @{
            Enable = $true
        }

        PSShouldProcess = @{
            Enable = $true
        }

        PSAvoidDefaultValueSwitchParameter = @{
            Enable = $true
        }

        PSUseDeclaredVarsMoreThanAssignments = @{
            Enable = $true
        }

        PSAvoidUsingPlainTextForPassword = @{
            Enable = $true
        }

        PSAvoidUsingConvertToSecureStringWithPlainText = @{
            Enable = $true
        }

        PSAvoidUsingComputerNameHardcoded = @{
            Enable = $true
        }

        PSAvoidUsingDeprecatedManifestFields = @{
            Enable = $true
        }

        PSAvoidUsingEmptyCatchBlock = @{
            Enable = $true
        }

        PSAvoidUsingInvokeExpression = @{
            Enable = $true
        }

        PSAvoidUsingPositionalParameters = @{
            Enable = $false  # Set to $true for stricter parameter checking
        }

        PSAvoidGlobalVars = @{
            Enable = $false  # Set to $true to warn about global variables
        }

        PSUseCmdletCorrectly = @{
            Enable = $true
        }

        PSUseSingularNouns = @{
            Enable = $true
        }

        PSMisleadingBacktick = @{
            Enable = $true
        }

        PSAvoidShouldContinueWithoutForce = @{
            Enable = $true
        }

        PSReviewUnusedParameter = @{
            Enable = $true
        }

        PSUseSupportsShouldProcess = @{
            Enable = $true
        }

        PSAvoidLongLines = @{
            Enable = $true
            MaximumLineLength = 120
        }

        PSAvoidMultipleTypeAttributes = @{
            Enable = $true
        }

        PSAvoidSemicolonsAsLineTerminators = @{
            Enable = $true
        }

        PSAvoidUsingDoubleQuotesForConstantString = @{
            Enable = $false  # Single quotes preferred but not enforced
        }
    }
}
