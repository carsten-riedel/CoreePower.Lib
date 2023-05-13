if (-not ([System.Management.Automation.PSTypeName]'ModuleRecordState').Type) {
    Add-Type @"
    public enum ModuleRecordState {
        Latest,
        Previous,
        All
    }
"@
}

if (-not ([System.Management.Automation.PSTypeName]'ModuleScope').Type) {
    Add-Type @"
    public enum ModuleScope {
        CurrentUser,
        LocalMachine
    }
"@
}

