#Requires Autohotkey v2.0

CheckForUpdates() {
    global repoOwner, repoName

    if (!UpdateMessages.Value) {
        return
    }

    url := "https://api.github.com/repos/" repoOwner "/" repoName "/releases/latest"
    http := ComObject("MSXML2.XMLHTTP")
    http.Open("GET", url, false)
    http.Send()

    if (http.Status != 200) {
        AddToLog("Failed to check for updates.")
        return
    }

    response := http.responseText
    latestVersion := JSON.parse(response).Get("tag_name")

    ; Compare versions using VerCompare
    comparison := VerCompare(currentVersion, latestVersion)

    if (comparison < 0) {
        AddToLog("🔄 Update available! Current: " currentVersion " → Latest: " latestVersion)
    } else if (comparison > 0) {
        AddToLog("🚨 Your version is newer than the latest published version (" latestVersion ")")
    } else {
        AddToLog("✅ You are already using the latest version (" currentVersion ")")
    }
}