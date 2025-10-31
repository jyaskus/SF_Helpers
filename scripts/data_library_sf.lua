
function onInit()

	aRecordOverrides = {
		["organization"] = {
			bExport = true,
			aDataMap = { "organizations", "reference.organizations" },
			sSidebarCategory = "world",
			fGetLink = openORGlist,
			},
		}

	LibraryData.overrideRecordTypes(aRecordOverrides);

end

function openORGlist()
	local dbRootName = "organizations";
	local createRequestWindowName = "popup_orgs";

	Interface.openWindow(createRequestWindowName, dbRootName);
end
