Function Set-SyncLibraryItem {
<#
	.NOTES
	------------------------------------------------------
	AUTHOR		: LOKESH HK
	ORGANISATION: VMWARE
        
	------------------------------------------------------
	.DESCRIPTION
		This function sync all the items in the library or given individual item.
	.PARAMETER	LibraryName
		Name of the library
	.PARAMETER	LibraryItemName
		Name of the Library Item
	.EXAMPLE
		Set-SyncLibraryItem -LibraryName 'LibraryName'
		Set-SyncLibraryItem -LibraryName 'LibraryName' -LibraryItemName 'LibrraryItemName'
#>

	param(
		[Parameter(Mandatory=$true)][string]$LibraryName,
		[Parameter(Mandatory=$false)][string]$LibraryItemName
	)
	
	$ContentLibraryService = Get-CisService com.vmware.content.library
	$libaryIDs = $contentLibraryService.list()
	foreach($libraryID in $libaryIDs) {
        $library = $contentLibraryService.get($libraryID)
		if($library.name -eq $LibraryName){
			$library_ID = $libraryID			
			break
		}
	}
	if(!$library_ID){
		write-host $LibraryName "-- Library is not exists .."
	} else {
		$ContentLibraryItemListService = Get-CisService "com.vmware.content.library.item"
		$LibItemListIds = $ContentLibraryItemListService.list($library_ID)
		if(!$LibItemListIds) {
			write-host " No library items are found in the Library to sync, hence aborting.."
		} else {
			$ContentLibraryItemSyncService  = Get-CisService "com.vmware.content.library.subscribed_item"
			foreach( $LibItemListId in $LibItemListIds){
				if($LibraryItemName) {
					$LibraryItem = $ContentLibraryItemListService.get($LibItemListId)
					if($LibraryItemName -eq $LibraryItem.name) {continue}
						write-host "Synching Library Item " $LibraryItem.name
						$ContentLibraryItemSyncService.sync($LibItemListId,$true)
						break
				}
			$LibraryItem = $ContentLibraryItemListService.get($LibItemListId)
			write-host "Synching Library Item " $LibraryItem.name
			$ContentLibraryItemSyncService.sync($LibItemListId,$true)
			}
		}
	}
}