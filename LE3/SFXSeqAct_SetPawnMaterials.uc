Class SFXSeqAct_SetPawnMaterials extends SequenceAction;

enum FBioPawnComponent
{
    BioPawnComponent_Mesh,
    BioPawnComponent_Head,
    BioPawnComponent_Hair,
    BioPawnComponent_Headgear,
    BioPawnComponent_Visor,
    BioPawnComponent_FacePlate,
    BioPawnComponent_Accessory,
};

var(SFXSeqAct_SetPawnMaterials) FBioPawnComponent m_eBioPawnComponent;
var(SFXSeqAct_SetPawnMaterials) array<MaterialInterface> m_aoMaterials;
var(SFXSeqAct_SetPawnMaterials) int m_nAccessory;

public function Activated()
{
    local Object ChkObject;
    local BioPawn Pawn;
    
    foreach Targets(ChkObject, )
    {
        Pawn = BioPawn(ChkObject);
        if (Pawn != None)
        {
            switch (m_eBioPawnComponent)
            {
                case FBioPawnComponent.BioPawnComponent_Mesh:
                    SetComponentMaterials(Pawn, Pawn.Mesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_Head:
                    SetComponentMaterials(Pawn, Pawn.HeadMesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_Hair:
                    SetComponentMaterials(Pawn, Pawn.m_oHairMesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_Headgear:
                    SetComponentMaterials(Pawn, Pawn.m_oHeadgearMesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_Visor:
                    SetComponentMaterials(Pawn, Pawn.m_oVisorMesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_FacePlate:
                    SetComponentMaterials(Pawn, Pawn.m_oFacePlateMesh);
                    break;
                case FBioPawnComponent.BioPawnComponent_Accessory:
                    if (Pawn.m_aoAccessories.Length > m_nAccessory)
                    {
                        SetComponentMaterials(Pawn, Pawn.m_aoAccessories[m_nAccessory]);
                    }
                    break;
                default:
            }
        }
    }
}
public function SetComponentMaterials(BioPawn InPawn, SkeletalMeshComponent InComponent)
{
    local MaterialInstanceConstant MIC;
    local int idx;
    
    if (InComponent == None)
    {
        return;
    }
    for (idx = 0; idx < InComponent.SkeletalMesh.Materials.Length; ++idx)
    {
        if (m_aoMaterials.Length != 0 && m_aoMaterials[idx] != None)
        {
            MIC = new (InComponent) Class'MaterialInstanceConstant';
            MIC.SetParent(m_aoMaterials[idx]);
            InComponent.SetMaterial(idx, MIC);
        }
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    bCallHandler = FALSE
    VariableLinks = ({
                      LinkedVariables = (), 
                      LinkDesc = "Pawn", 
                      ExpectedType = Class'SeqVar_Object', 
                      LinkVar = 'None', 
                      PropertyName = 'Targets', 
                      CachedProperty = None, 
                      MinVars = 1, 
                      MaxVars = 255, 
                      bWriteable = FALSE, 
                      bModifiesLinkedObject = FALSE, 
                      bAllowAnyType = FALSE
                     }
                    )
}