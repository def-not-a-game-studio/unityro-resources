using UnityEngine;

[CreateAssetMenu(fileName = "StatusWindowSourceScriptableObject", menuName = "Scriptable Objects/StatusWindowSourceScriptableObject")]
public class StatusWindowSourceScriptableObject : ScriptableObject
{
    public string Name;
    public string JobName;
    public long Hp;
    public long MaxHp;
    public long Sp;
    public long MaxSp;
    
    public string CurrentHpPercent;
    public string CurrentSpPercent;

    public short BaseLevel;
    public short JobLevel;
    
    public long BaseExp;
    public long NextBaseExp;
    public long JobExp;
    public long NextJobExp;

    public string Weight;
    public long Money;
    
    public string Str;
    public string Agi;
    public string Vit;
    public string Int;
    public string Dex;
    public string Luk;

    public int StrBonus;
    public int AgiBonus;
    public int VitBonus;
    public int IntBonus;
    public int DexBonus;
    public int LukBonus;

    public string Atk;
    public string Def;
    public string Matk;
    public string Mdef;
    public string Hit;
    public string Flee;
    public string Critical;
    public string Aspd;
    public string StatusPoints;
    public string Guild;
    
    public string Patk;
    public string Smatk;
    public string Res;
    public string Mres;
    public string Hplus;
    public string Crate;
    public string TraitPoints;
    public string Ap;
    public string MaxAp;
}
