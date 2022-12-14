//created by Toothie & just-ero

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
		vars.Helper["loading"] = bootstrap.Make<bool>("LoadingSceneFromBootstrap");

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
	current.loading = vars.Helper["loading"].Current;
}

start
{
    return (current.TotalPlayTime + current.UnscaledTime - current.LastSaveT ime) < 1;
}

split
{}

reset
{}

gameTime
{
	//old
    //if(!current.IsLoadingLevel){
        //return TimeSpan.FromSeconds(current.TotalPlayTime + current.UnscaledTime - current.LastSaveTime);
    //}	
}

isLoading
{
	return current.loading;
}

exit
{
	vars.Helper.Dispose();
}

shutdown
{
	vars.Helper.Dispose();
}
