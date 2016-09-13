
if (window.analysised == undefined)
{
    window.analysised = true;
    if (document.readyState == "complete") {
        if (window.performance != undefined) {
            readPerformanceTiming(window.performance.timing);
        } else {
            readPerformanceTiming(window.timing);
        }
    } else {
        if (window.performance != undefined) {
            window.addEventListener("load", function(){readPerformanceTiming(window.performance.timing);}, false);
        } else {
            window.addEventListener("load", function(){readPerformanceTiming(window.timing);}, false);
        }
    }
}


