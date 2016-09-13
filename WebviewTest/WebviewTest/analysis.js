
if (window.injected == undefined) {
    window.injected = true;
    if (window.performance == undefined) {
        window.performance = {};
        window.performance.timing = {};
        window.performance.timing.domLoading = (new Date()).getTime();
        window.performance.timing.responseEnd = %@;
        window.addEventListener("DOMContentLoaded",
                                function() {
                                    window.performance.timing.domContentLoadedEventStart = (new Date()).getTime();
                                });
        window.addEventListener("load",
                                function() {
                                    window.performance.timing.loadEventEnd = (new Date()).getTime()
                                });
    } else if (window.performance.timing == undefined) {
        window.performance.timing = {};
        window.performance.timing.domLoading = (new Date()).getTime();
        window.performance.timing.responseEnd = %@;
        window.addEventListener("DOMContentLoaded",
                                function() {
                                    window.performance.timing.domContentLoadedEventStart = (new Date()).getTime();
                                });
        window.addEventListener("load",
                                function() {
                                    window.performance.timing.loadEventEnd = (new Date()).getTime()
                                });
    }
}



