({
    onPageReferenceChange: function (component) {
        var myPageRef = component.get('v.pageReference');
        component.set('v.code', myPageRef.state.c__code);
        component.set('v.recordId', myPageRef.state.c__recordId);
      },
})
