using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Text.Json;
using System.Threading;
using HarmonyLib;

public static class StartupHook
{
    private const int Port = 24060;
    private static readonly object Gate = new object();
    private static object _player;
    private static object _results;
    private static object _game;
    private static bool _loggedBeatmap;
    private static Harmony _harmony;

    public static void Initialize()
    {
        AppDomain.CurrentDomain.AssemblyResolve += (_, args) =>
        {
            var name = new AssemblyName(args.Name).Name;
            if (name == "0Harmony")
            {
                var here = Path.GetDirectoryName(typeof(StartupHook).Assembly.Location);
                var dll = Path.Combine(here ?? ".", "0Harmony.dll");
                if (File.Exists(dll)) return Assembly.LoadFrom(dll);
            }
            return null;
        };
        Log("hook-loaded pid=" + Environment.ProcessId + " runtime=" + Environment.Version);
        new Thread(Watch) { IsBackground = true, Name = "osu-telemetry-watch" }.Start();
    }

    private static void Watch()
    {
        var deadline = DateTime.UtcNow.AddMinutes(5);
        while (DateTime.UtcNow < deadline)
        {
            try
            {
                var osuGame = AppDomain.CurrentDomain.GetAssemblies()
                    .FirstOrDefault(a => a.GetName().Name == "osu.Game");
                if (osuGame != null)
                {
                    if (Debug) DumpStatics(osuGame);
                    if (Environment.GetEnvironmentVariable("OSU_HOOK_NOPATCH") != "1")
                        Patch(osuGame);
                    else
                        Log("NOPATCH=1: skipping Harmony entirely");
                    break;
                }
            }
            catch (Exception e) { Log("watch: " + e.Message); }
            Thread.Sleep(250);
        }
        Serve();
    }

    private static void DumpStatics(Assembly osuGame)
    {
        foreach (var name in new[] { "osu.Game.OsuGame", "osu.Game.OsuGameBase",
                                     "osu.Framework.Game", "osu.Framework.Platform.GameHost",
                                     "osu.Framework.Graphics.Drawable" })
        {
            Type t = osuGame.GetType(name) ?? Type.GetType(name + ", osu.Framework");
            if (t == null) { Log("static: type " + name + " not found"); continue; }
            foreach (var f in t.GetFields(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic))
            {
                object v = null;
                try { v = f.GetValue(null); } catch { }
                Log($"static-field {name}.{f.Name} : {f.FieldType.Name} = {(v == null ? "null" : v.GetType().Name)}");
            }
            foreach (var p in t.GetProperties(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic))
            {
                object v = null;
                try { v = p.GetValue(null); } catch { }
                Log($"static-prop {name}.{p.Name} : {p.PropertyType.Name} = {(v == null ? "null" : v.GetType().Name)}");
            }
        }
    }

    private static void Patch(Assembly osuGame)
    {
        _harmony = new Harmony("stream.osu.telemetry");

        var osuGameType = osuGame.GetType("osu.Game.OsuGame");
        if (osuGameType != null)
        {
            PatchMethod(osuGameType, "UpdateAfterChildren", nameof(GameTick));
            PatchMethod(osuGameType, "screenPushed", nameof(ScreenPushed));
            PatchMethod(osuGameType, "screenExited", nameof(ScreenExited));
        }
        else Log("OsuGame type not found");

        if (!Debug) return;

        var spType = osuGame.GetType("osu.Game.Rulesets.Scoring.ScoreProcessor")
                     ?? osuGame.GetType("osu.Game.Scoring.ScoreProcessor");
        if (spType != null)
        {
            Log("ScoreProcessor type: " + spType.FullName);
            foreach (var p in spType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                Log($"SP prop {p.Name} : {p.PropertyType.Name}");
            foreach (var m in spType.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance)
                         .Where(m => m.Name.Contains("Count") || m.Name.Contains("Statistic")))
                Log($"SP method {m.Name}({string.Join(",", m.GetParameters().Select(p => p.ParameterType.Name))})");
        }
        else Log("ScoreProcessor type not found");

        var gsType = osuGame.GetType("osu.Game.Screens.Play.GameplayState");
        if (gsType != null)
            foreach (var p in gsType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (p.Name.Contains("Mod") || p.Name.Contains("Beatmap") || p.Name.Contains("Score"))
                    Log($"GameplayState prop {p.Name} : {p.PropertyType.Name}");

        var hrType = osuGame.GetType("osu.Game.Rulesets.Scoring.HitResult");
        if (hrType != null) Log("HitResult values: " + string.Join(",", Enum.GetNames(hrType)));

        var drType = osuGame.GetType("osu.Game.Rulesets.UI.DrawableRuleset");
        if (drType != null)
            foreach (var p in drType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (p.Name.Contains("Mod")) Log($"DrawableRuleset prop {p.Name} : {p.PropertyType.Name}");

        var rulesetType = osuGame.GetType("osu.Game.Rulesets.Ruleset");
        if (rulesetType != null)
            foreach (var m in rulesetType.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (m.Name.Contains("Performance") || m.Name.Contains("Difficulty") || m.Name.Contains("CreateScore"))
                    Log($"Ruleset method {m.Name}({string.Join(",", m.GetParameters().Select(p => p.ParameterType.Name))})");

        var pcType = osuGame.GetType("osu.Game.Rulesets.Difficulty.PerformanceCalculator");
        if (pcType != null)
            foreach (var m in pcType.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (m.Name.Contains("Calculate")) Log($"PerfCalc method {m.Name}({string.Join(",", m.GetParameters().Select(p => p.ParameterType.Name))}) : {m.ReturnType.Name}");

        var siType = osuGame.GetType("osu.Game.Scoring.ScoreInfo");
        if (siType != null)
            foreach (var p in siType.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (p.CanWrite) Log($"ScoreInfo writable prop {p.Name} : {p.PropertyType.Name}");
    }

    private static void GameTick(object __instance) { _game = __instance; }

    private static bool _playerMethodPatched;

    private static void ScreenPushed(object __0)
    {
        if (__0 == null) return;
        var t = __0.GetType();
        if (Debug) Log("pushed " + t.Name);
        if (IsPlayerType(t)) lock (Gate) { _player = __0; _results = null; }
        else if (t.Name == "ResultsScreen") lock (Gate) { _results = __0; _player = null; }
    }

    private static void ScreenExited(object __0)
    {
        if (__0 == null) return;
        var t = __0.GetType();
        if (Debug) Log("exited " + t.Name);
        lock (Gate)
        {
            if (IsPlayerType(t)) _player = null;
            if (t.Name == "ResultsScreen") _results = null;
        }
    }

    private static bool IsPlayerType(Type t)
    {
        for (var b = t; b != null; b = b.BaseType)
            if (b.Name == "Player") return true;
        return false;
    }

    private static bool IsResultsType(Type t)
    {
        for (var b = t; b != null; b = b.BaseType)
            if (b.Name.Contains("ResultsScreen")) return true;
        return false;
    }

    private static void DumpMethods(Type t)
    {
        foreach (var m in t.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly))
            Log($"method {t.Name}.{m.Name}({string.Join(",", m.GetParameters().Select(p => p.ParameterType.Name))})");
    }

    private static void PatchMethod(Type type, string name, string hookName)
    {
        var m = type.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic)
            .FirstOrDefault(mm => mm.Name == name && !mm.IsSpecialName);
        if (m == null) { Log($"method {type.Name}.{name} not found"); return; }
        try
        {
            _harmony.Patch(m, postfix: new HarmonyMethod(typeof(StartupHook).GetMethod(hookName, BindingFlags.Static | BindingFlags.NonPublic)));
            if (hookName == nameof(PlayerTick)) _playerMethodPatched = true;
            Log($"patched {type.Name}.{name}({string.Join(",", m.GetParameters().Select(p => p.ParameterType.Name))})");
        }
        catch (Exception e) { Log($"patch {type.Name}.{name}: {e.Message}"); }
    }

    private static void PlayerTick(object __instance)
    {
        lock (Gate) { _player = __instance; _results = null; }
    }

    private static void ResultsTick(object __instance)
    {
        lock (Gate) { _results = __instance; _player = null; }
    }

    // ---- telemetry server -------------------------------------------------

    private static void Serve()
    {
        TcpListener listener;
        try { listener = new TcpListener(IPAddress.Loopback, Port); listener.Start(); }
        catch (Exception e) { Log("listen failed: " + e.Message); return; }
        Log("telemetry server on 127.0.0.1:" + Port);
        while (true)
        {
            try
            {
                var client = listener.AcceptTcpClient();
                var t = new Thread(() => Stream(client)) { IsBackground = true };
                t.Start();
            }
            catch (Exception e) { Log("accept: " + e.Message); Thread.Sleep(500); }
        }
    }

    private static void Stream(TcpClient client)
    {
        try
        {
            using var ns = client.GetStream();
            using var w = new StreamWriter(ns, new UTF8Encoding(false)) { AutoFlush = true };
            while (client.Connected)
            {
                string json;
                try { json = Snapshot(); } catch (Exception e) { json = "{\"state\":\"error\",\"error\":" + JsonSerializer.Serialize(e.Message) + "}"; }
                w.WriteLine(json);
                Thread.Sleep(100);
            }
        }
        catch { }
    }

    // ---- snapshot ---------------------------------------------------------

    private static string Snapshot()
    {
        object player = null, results = null;

        var cur = CurrentScreen();
        if (cur != null)
        {
            var ct = cur.GetType();
            if (IsResultsType(ct)) { results = cur; }
            else if (IsPlayerType(ct)) { player = cur; }
            else
            {
                var p = Member(cur, "Player");
                if (p != null && IsPlayerType(p.GetType())) player = p;
            }
        }

        if (cur == null)
        {
            lock (Gate) { player = _player; results = _results; }
        }

        using var ms = new MemoryStream();
        using var jw = new Utf8JsonWriter(ms);

        jw.WriteStartObject();
        if (player != null && !IsDisposed(player))
        {
            jw.WriteString("state", "playing");
            WriteScore(jw, player);
        }
        else if (results != null && !IsDisposed(results))
        {
            jw.WriteString("state", "result");
            WriteResults(jw, results);
        }
        else
        {
            jw.WriteString("state", "menu");
        }
        WriteProfile(jw);
        jw.WriteEndObject();
        jw.Flush();
        return Encoding.UTF8.GetString(ms.ToArray());
    }

    private static void WriteScore(Utf8JsonWriter jw, object player)
    {
        var sp = Member(player, "ScoreProcessor");
        if (sp is IDisposable d && IsDisposed(sp)) return;

        var beatmap = Unwrap(FirstNonNull(
            Member(player, "Beatmap"),
            Member(Member(player, "GameplayState"), "Beatmap"),
            Member(Member(player, "DrawableRuleset"), "Beatmap")));

        jw.WriteNumber("score", ToLong(FirstNonNull(Value(sp, "TotalScore"), Value(sp, "Score"))));
        jw.WriteNumber("acc", Math.Round(ToDouble(Value(sp, "Accuracy")) * 100, 2));
        jw.WriteNumber("combo", ToLong(Value(sp, "Combo")));
        jw.WriteNumber("maxCombo", ToLong(Value(sp, "HighestCombo")));

        var comboLimit = (int)ToLong(Member(sp, "MaximumCombo"));
        jw.WriteNumber("comboLimit", comboLimit);

        var pp = ComputePP(player, beatmap);
        if (pp.HasValue) jw.WriteNumber("pp", Math.Round(pp.Value, 2));
        else jw.WriteNumber("pp", 0);

        var maxPp = ComputeMaxPP(player, beatmap, comboLimit);
        if (maxPp.HasValue) jw.WriteNumber("maxPp", Math.Round(maxPp.Value, 2));
        else jw.WriteNumber("maxPp", 0);

        jw.WriteStartObject("counts");
        WriteCounts2(jw, sp);
        jw.WriteEndObject();

        var mods = ReadMods(player);
        jw.WriteStartArray("mods");
        foreach (var m in mods) jw.WriteStringValue(m);
        jw.WriteEndArray();

        WriteBeatmap(jw, beatmap);
    }

    private static void WriteResults(Utf8JsonWriter jw, object results)
    {
        var score = Member(results, "Score");
        var bp = Unwrap(FirstNonNull(Member(results, "Beatmap"), Member(Member(results, "GameplayState"), "Beatmap")));
        jw.WriteNumber("score", ToLong(Value(score, "TotalScore")));
        jw.WriteNumber("acc", Math.Round(ToDouble(Value(score, "Accuracy")) * 100, 2));
        jw.WriteNumber("maxCombo", ToLong(Value(score, "MaxCombo")));
        var rank = Value(score, "Rank");
        if (rank != null) jw.WriteString("rank", rank.ToString());
        WriteBeatmap(jw, bp);
    }

    private static void WriteBeatmap(Utf8JsonWriter jw, object beatmap)
    {
        if (beatmap == null) return;
        if (Debug && !_loggedBeatmap)
        {
            _loggedBeatmap = true;
            Log("beatmap type: " + beatmap.GetType().FullName);
            foreach (var p in beatmap.GetType().GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                if (p.Name.Contains("Info") || p.Name.Contains("Meta") || p.Name.Contains("Difficulty") || p.Name.Contains("ID"))
                    Log($"beatmap prop {p.Name} : {p.PropertyType.Name}");
        }
        var meta = FirstNonNull(Member(beatmap, "Metadata"), Member(Member(beatmap, "BeatmapInfo"), "Metadata"));
        var bi = Unwrap(FirstNonNull(Member(beatmap, "BeatmapInfo"), Member(Unwrap(Member(beatmap, "Beatmap")), "BeatmapInfo")));
        var diff = Unwrap(Member(bi, "Difficulty"));
        jw.WriteStartObject("beatmap");
        jw.WriteString("artist", ToString(Member(meta, "Artist")));
        jw.WriteString("title", ToString(Member(meta, "Title")));
        jw.WriteString("version", ToString(FirstNonNull(Member(bi, "DifficultyName"), Member(beatmap, "DifficultyName"), Member(meta, "DifficultyName"))));
        jw.WriteNumber("id", ToLong(FirstNonNull(Member(bi, "OnlineID"), Member(beatmap, "OnlineID"))));
        jw.WriteString("mapper", ToString(FirstNonNull(Member(Member(meta, "Author"), "Username"), Member(meta, "Author"))));
        jw.WriteNumber("stars", Math.Round(ToDouble(FirstNonNull(Member(bi, "StarRating"), Member(beatmap, "StarRating"))), 2));
        jw.WriteNumber("ar", Math.Round(ToDouble(Member(diff, "ApproachRate")), 1));
        jw.WriteNumber("cs", Math.Round(ToDouble(Member(diff, "CircleSize")), 1));
        jw.WriteNumber("od", Math.Round(ToDouble(Member(diff, "OverallDifficulty")), 1));
        jw.WriteNumber("hp", Math.Round(ToDouble(Member(diff, "DrainRate")), 1));
        jw.WriteNumber("bpm", Math.Round(ToDouble(FirstNonNull(Member(bi, "BPM"), Member(beatmap, "BPM"))), 1));
        var lengthObj = FirstNonNull(Member(bi, "Length"), Member(beatmap, "Length"));
        double lenSecs = lengthObj is TimeSpan lts ? lts.TotalSeconds : ToDouble(lengthObj);
        if (lenSecs > 36000) lenSecs /= 1000;
        jw.WriteNumber("length", Math.Round(lenSecs, 0));
        jw.WriteNumber("objects", ToLong(FirstNonNull(Member(bi, "TotalObjectCount"), Member(beatmap, "TotalObjectCount"))));
        jw.WriteEndObject();
    }

    private static double ToSeconds(object o)
    {
        if (o is TimeSpan ts) return ts.TotalSeconds;
        return ToDouble(o);
    }

    private static void WriteCounts2(Utf8JsonWriter jw, object sp)
    {
        var map = new Dictionary<string, int>();
        try
        {
            if (Member(sp, "Statistics") is IEnumerable en)
            {
                foreach (var kv in en)
                {
                    var k = Member(kv, "Key");
                    var v = Member(kv, "Value");
                    if (k != null && v != null) map[k.ToString()] = Convert.ToInt32(v);
                }
            }
        }
        catch { }
        int C(string n) => map.TryGetValue(n, out var x) ? x : 0;
        jw.WriteNumber("300", C("Great"));
        jw.WriteNumber("100", C("Ok"));
        jw.WriteNumber("50", C("Meh"));
        jw.WriteNumber("miss", C("Miss"));
        jw.WriteNumber("geki", C("Perfect"));
        jw.WriteNumber("katu", C("Good"));
    }

    private static void WriteCount(Utf8JsonWriter jw, object sp, string key, string hitResultName)
    {
        jw.WriteNumber(key, Count(sp, hitResultName));
    }

    private static int Count(object sp, string hitResultName)
    {
        try
        {
            var asm = sp.GetType().Assembly;
            var hrType = asm.GetType("osu.Game.Rulesets.Scoring.HitResult");
            if (hrType != null)
            {
                var method = sp.GetType().GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance)
                    .FirstOrDefault(m => m.Name == "GetCount" && m.GetParameters().Length >= 1
                                         && m.GetParameters()[0].ParameterType == hrType);
                if (method != null)
                {
                    var val = Enum.Parse(hrType, hitResultName);
                    var args = method.GetParameters().Length == 1 ? new object[] { val } : new object[] { val, false };
                    return Convert.ToInt32(method.Invoke(sp, args));
                }
            }
        }
        catch { }
        return 0;
    }

    private static List<string> ReadMods(object player)
    {
        var list = new List<string>();
        try
        {
            var modsObj = Value(player, "Mods")
                          ?? Value(Member(player, "GameplayState"), "Mods")
                          ?? Value(Member(player, "DrawableRuleset"), "Mods");
            if (modsObj is IEnumerable en && !(modsObj is string))
            {
                foreach (var m in en)
                {
                    var acr = Member(m, "Acronym");
                    if (acr != null) list.Add(acr.ToString());
                }
            }
        }
        catch { }
        return list;
    }

    // ---- reflection helpers ----------------------------------------------

    private static double? _lastPP;
    private static DateTime _lastPPAt = DateTime.MinValue;
    private static double? _lastMaxPP;
    private static DateTime _lastMaxPPAt = DateTime.MinValue;
    private static readonly bool Debug = Environment.GetEnvironmentVariable("OSU_HOOK_DEBUG") == "1";
    private static readonly HashSet<string> _logged = new HashSet<string>();

    private static void LogOnce(string msg)
    {
        lock (_logged)
        {
            if (!_logged.Add(msg)) return;
        }
        Log(msg);
    }

    private static double? ComputePP(object player, object working)
    {
        if (working == null) return _lastPP;
        if ((DateTime.UtcNow - _lastPPAt).TotalSeconds < 4) return _lastPP;
        _lastPPAt = DateTime.UtcNow;
        try
        {
            var score = Unwrap(Member(player, "Score"));
            var si = Unwrap(Member(score, "ScoreInfo"));
            if (si == null) { LogOnce("pp: no ScoreInfo"); return _lastPP; }

            var bi = Unwrap(FirstNonNull(Member(working, "BeatmapInfo"), Member(Unwrap(Member(working, "Beatmap")), "BeatmapInfo")));
            var rsInfo = Member(bi, "Ruleset");
            var ruleset = Invoke(rsInfo, "CreateInstance", null, Array.Empty<object>());
            var calc = Invoke(ruleset, "CreatePerformanceCalculator", null, Array.Empty<object>());
            if (calc == null) { LogOnce("pp: no calculator"); return _lastPP; }

            object attrs = null;
            attrs = Invoke(calc, "Calculate", new[] { si.GetType(), working.GetType() }, new object[] { si, working });
            if (attrs == null) { LogOnce("pp: calculate returned null"); return _lastPP; }

            var total = Member(attrs, "Total");
            if (total != null) _lastPP = ToDouble(total);
            return _lastPP;
        }
        catch (Exception e)
        {
            LogOnce("pp err: " + e.Message);
            return _lastPP;
        }
    }

    private static object Invoke(object o, string name, Type[] types, object[] args)
    {
        if (o == null) return null;
        foreach (var m in o.GetType().GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
        {
            if (m.Name != name) continue;
            var ps = m.GetParameters();
            if (ps.Length != args.Length) continue;
            if (types != null)
            {
                bool ok = true;
                for (int i = 0; i < ps.Length; i++)
                    if (types[i] != null && !ps[i].ParameterType.IsAssignableFrom(types[i])) { ok = false; break; }
                if (!ok) continue;
            }
            try { return m.Invoke(o, args); }
            catch (Exception e) { throw new Exception(name + ": " + (e.InnerException?.Message ?? e.Message)); }
        }
        return null;
    }

    private static double? ComputeMaxPP(object player, object working, int comboLimit)
    {
        if (working == null || comboLimit <= 0) return _lastMaxPP;
        if ((DateTime.UtcNow - _lastMaxPPAt).TotalSeconds < 5) return _lastMaxPP;
        _lastMaxPPAt = DateTime.UtcNow;
        try
        {
            var score = Unwrap(Member(player, "Score"));
            var live = Unwrap(Member(score, "ScoreInfo"));
            if (live == null) { LogOnce("maxpp: no ScoreInfo"); return _lastMaxPP; }

            var sp = Member(player, "ScoreProcessor");
            var maxStats = Member(live, "MaximumStatistics") ?? Member(sp, "MaximumStatistics");
            if (maxStats == null) { LogOnce("maxpp: no MaximumStatistics"); return _lastMaxPP; }

            var oldStats = Member(live, "Statistics");
            var oldMax = Member(live, "MaxCombo");
            var oldAcc = Member(live, "Accuracy");
            var oldCombo = Member(live, "Combo");
            var oldPassed = Member(live, "Passed");

            var bi = Unwrap(FirstNonNull(Member(working, "BeatmapInfo"), Member(Unwrap(Member(working, "Beatmap")), "BeatmapInfo")));
            var rsInfo = Member(bi, "Ruleset");
            var ruleset = Invoke(rsInfo, "CreateInstance", null, Array.Empty<object>());
            var calc = Invoke(ruleset, "CreatePerformanceCalculator", null, Array.Empty<object>());
            if (calc == null) { LogOnce("maxpp: no calculator"); return _lastMaxPP; }

            try
            {
                Set(live, "Statistics", maxStats);
                Set(live, "MaxCombo", comboLimit);
                Set(live, "Accuracy", 1.0);
                Set(live, "Combo", comboLimit);
                Set(live, "Passed", true);

                var attrs = Invoke(calc, "Calculate", new[] { live.GetType(), working.GetType() }, new object[] { live, working });
                if (attrs == null) { LogOnce("maxpp: attrs null"); return _lastMaxPP; }
                var total = Member(attrs, "Total");
                if (total == null) { LogOnce("maxpp: no Total on " + attrs.GetType().Name); return _lastMaxPP; }
                _lastMaxPP = ToDouble(total);
            }
            finally
            {
                Set(live, "Statistics", oldStats);
                Set(live, "MaxCombo", oldMax);
                Set(live, "Accuracy", oldAcc);
                Set(live, "Combo", oldCombo);
                Set(live, "Passed", oldPassed);
            }
            return _lastMaxPP;
        }
        catch (Exception e)
        {
            LogOnce("maxpp err: " + e.Message);
            return _lastMaxPP;
        }
    }

    private static void Set(object o, string name, object val)
    {
        var t = o?.GetType();
        while (t != null)
        {
            var p = t.GetProperty(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (p != null && p.CanWrite) { try { p.SetValue(o, val); return; } catch { } }
            var f = t.GetField(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (f != null) { try { f.SetValue(o, val); return; } catch { } }
            t = t.BaseType;
        }
    }

    private class Prof
    {
        public string name = "", country = "";
        public long id, pp, gRank, cRank, playCount, totalScore, rankedScore, totalHits, maxCombo;
        public double acc, level;
        public DateTime at = DateTime.MinValue;
    }

    private static Prof _prof;
    private static bool _profDumped;

    private static void WriteProfile(Utf8JsonWriter jw)
    {
        try
        {
            if (_prof == null || (DateTime.UtcNow - _prof.at).TotalMinutes > 10)
            {
                var api = Member(_game, "API");
                var user = Unwrap(Member(api, "LocalUser"));

                if (Debug && !_profDumped)
                {
                    _profDumped = true;
                    Log("profile: game=" + (_game?.GetType().FullName ?? "null") + " api=" + (api?.GetType().FullName ?? "null") + " user=" + (user?.GetType().FullName ?? "null"));
                    if (api != null)
                        foreach (var p in api.GetType().GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                            if (p.Name.Contains("User") || p.Name.Contains("State") || p.Name.Contains("Local"))
                                Log($"api prop {p.Name} : {p.PropertyType.Name}");
                    if (user != null)
                        foreach (var p in user.GetType().GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
                            Log($"APIUser prop {p.Name} : {p.PropertyType.Name}");
                }

                if (user == null) return;
                var st = Member(user, "Statistics");

                var prof = new Prof
                {
                    name = ToString(Member(user, "Username")),
                    country = ToString(FirstNonNull(Member(Member(user, "Country"), "FullName"), Member(user, "Country"), Member(user, "CountryCode"))),
                    id = ToLong(Member(user, "Id")),
                    pp = ToLong(Member(st, "PP")),
                    gRank = ToLong(Member(st, "GlobalRank")),
                    cRank = ToLong(Member(st, "CountryRank")),
                    acc = Math.Round(ToDouble(Member(st, "Accuracy")), 2),
                    playCount = ToLong(Member(st, "PlayCount")),
                    totalScore = ToLong(Member(st, "TotalScore")),
                    rankedScore = ToLong(Member(st, "RankedScore")),
                    totalHits = ToLong(Member(st, "TotalHits")),
                    maxCombo = ToLong(Member(st, "MaxCombo")),
                    level = ToDouble(FirstNonNull(Member(Member(st, "Level"), "Current"), Member(st, "Level"))),
                    at = DateTime.UtcNow,
                };
                if (prof.name == "" || (prof.pp <= 0 && prof.playCount <= 0))
                {
                    LogOnce("profile: stats not ready yet");
                    return;
                }
                _prof = prof;
            }
            if (_prof == null || _prof.name == "") return;
            jw.WritePropertyName("profile");
            jw.WriteStartObject();
            jw.WriteNumber("id", _prof.id);
            jw.WriteString("name", _prof.name);
            jw.WriteString("country", _prof.country);
            jw.WriteNumber("pp", _prof.pp);
            jw.WriteNumber("globalRank", _prof.gRank);
            jw.WriteNumber("countryRank", _prof.cRank);
            jw.WriteNumber("accuracy", _prof.acc);
            jw.WriteNumber("level", Math.Round(_prof.level, 2));
            jw.WriteNumber("playCount", _prof.playCount);
            jw.WriteNumber("totalScore", _prof.totalScore);
            jw.WriteNumber("rankedScore", _prof.rankedScore);
            jw.WriteNumber("totalHits", _prof.totalHits);
            jw.WriteNumber("maxCombo", _prof.maxCombo);
            jw.WriteEndObject();
        }
        catch (Exception e) { LogOnce("profile err: " + e.Message); }
    }

    private static object FirstNonNull(params object[] vals)
    {
        foreach (var v in vals) if (v != null) return v;
        return null;
    }

    private static object Unwrap(object o)
    {
        for (int i = 0; i < 4 && o != null; i++)
        {
            var v = Member(o, "Value");
            if (v == null) break;
            o = v;
        }
        return o;
    }

    private static object CurrentScreen()
    {
        var stack = Member(_game, "ScreenStack");
        if (stack == null) return null;
        var cur = Member(stack, "CurrentScreen");
        if (cur != null) return cur;
        if (Member(stack, "Screens") is IEnumerable en)
        {
            object last = null;
            foreach (var x in en) last = x;
            return last;
        }
        return null;
    }

    private static object Member(object o, string name)
    {
        if (o == null) return null;
        var t = o.GetType();
        while (t != null)
        {
            var p = t.GetProperty(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (p != null && p.GetIndexParameters().Length == 0)
            {
                try { return p.GetValue(o); } catch { }
            }
            var f = t.GetField(name, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            if (f != null)
            {
                try { return f.GetValue(o); } catch { }
            }
            t = t.BaseType;
        }
        return null;
    }

    // unwrap Bindable<T>
    private static object Value(object o, string name)
    {
        var v = Member(o, name);
        if (v == null) return null;
        var inner = Member(v, "Value");
        return inner ?? v;
    }

    private static bool IsDisposed(object o)
    {
        var v = Member(o, "IsDisposed");
        return v is bool b && b;
    }

    private static long ToLong(object o)
    {
        try { return o == null ? 0 : Convert.ToInt64(o); } catch { return 0; }
    }

    private static double ToDouble(object o)
    {
        try { return o == null ? 0 : Convert.ToDouble(o); } catch { return 0; }
    }

    private static string ToString(object o) => o == null ? "" : o.ToString();

    private static void Log(string msg)
    {
        try
        {
            File.AppendAllText("/tmp/osu-telemetry.log",
                DateTime.Now.ToString("HH:mm:ss.fff") + " " + msg + "\n");
        }
        catch { }
    }
}
