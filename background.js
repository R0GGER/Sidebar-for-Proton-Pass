// Toggle the Proton Pass sidebar when the toolbar icon is clicked.
browser.action.onClicked.addListener(() => {
  browser.sidebarAction.toggle();
});
