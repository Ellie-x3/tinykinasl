state("Tinykin")
{
	double UnscaledTime : "UnityPlayer.dll", 0x19EEC78, 0x70;
}

startup
{
	vars.Log = (Action<object>)(output => print("[GameName] " + output));

	var bytes = File.ReadAllBytes(@"Components\LiveSplit.ASLHelper.bin");
	var type = Assembly.Load(bytes).GetType("ASLHelper.Unity");
	vars.Helper = Activator.CreateInstance(type, timer, /* settings, */ this);
	// vars.Helper.LoadSceneManager = true;
}

onStart
{}

onSplit
{}

onReset
{}

init
{
	vars.Helper.TryOnLoad = (Func<dynamic, bool>)(mono =>
	{
		var g = mono.GetClass("Game", "Game");
		vars.Helper["TotalPlayTime"] = g.Make<float>("totalPlayTime");
		vars.Helper["LastSaveTime"] = g.Make<float>("INSTANCE", "lastSaveTime");

        var bootstrap = mono.GetClass("Game", "Bootstrap");
        vars.Helper["IsLoadingLevel"] = bootstrap.Make<bool>("IsLoadingLevel");

		return true;
	});

	vars.Helper.Load();
}

update
{
	if (!vars.Helper.Update())
		return false;

	current.TotalPlayTime = vars.Helper["TotalPlayTime"].Current;
	current.LastSaveTime = vars.Helper["LastSaveTime"].Current;
    current.IsLoadingLevel = vars.Helper["IsLoadingLevel"].Current;

	// current.Scene = vars.Helper.Scenes.Active.Index;
}

start
{
    return (current.TotalPlayTime + current.UnscaledTime - current.LastSaveTime) < 1;
}

split
{}

reset
{}

gameTime
{
    if(!current.IsLoadingLevel){
        return TimeSpan.FromSeconds(current.TotalPlayTime + current.UnscaledTime - current.LastSaveTime);
    }	
}

isLoading
{
	return true;
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}

