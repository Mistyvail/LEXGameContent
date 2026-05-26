Class SFXSeqAct_SetPawnMesh extends SequenceAction;

enum EBioPawnComponent
{
    BioPawnComponent_Mesh,
    BioPawnComponent_Head,
    BioPawnComponent_Hair,
    BioPawnComponent_Headgear,
    BioPawnComponent_Visor,
    BioPawnComponent_FacePlate,
    BioPawnComponent_Accessory,
};

var(SFXSeqAct_SetPawnMesh) EBioPawnComponent m_eBioPawnComponent;
var(SFXSeqAct_SetPawnMesh) SkeletalMesh m_oMesh;
var(SFXSeqAct_SetPawnMesh) array<MaterialInterface> m_aoMaterials;
var(SFXSeqAct_SetPawnMesh) int m_nAccessory;
var(SFXSeqAct_SetPawnMesh) bool m_bCreateComponent;
var(SFXSeqAct_SetPawnMesh) bool m_bPreserveAnimation;

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
                case EBioPawnComponent.BioPawnComponent_Mesh:
                    SetComponentMesh(Pawn, Pawn.Mesh, FALSE);
                    break;
                case EBioPawnComponent.BioPawnComponent_Head:
                    SetComponentMesh(Pawn, Pawn.HeadMesh, FALSE);
                    break;
                case EBioPawnComponent.BioPawnComponent_Hair:
                    SetComponentMesh(Pawn, Pawn.m_oHairMesh, m_bCreateComponent);
                    break;
                case EBioPawnComponent.BioPawnComponent_Headgear:
                    SetComponentMesh(Pawn, SFXPawn_Henchman(Pawn) != None ? SFXPawn_Henchman(Pawn).HelmetMesh : Pawn.m_oHeadGearMesh, m_bCreateComponent);
                    break;
                case EBioPawnComponent.BioPawnComponent_Visor:
                    SetComponentMesh(Pawn, Pawn.m_oVisorMesh, m_bCreateComponent);
                    break;
                case EBioPawnComponent.BioPawnComponent_FacePlate:
                    SetComponentMesh(Pawn, Pawn.m_oFacePlateMesh, m_bCreateComponent);
                    break;
                case EBioPawnComponent.BioPawnComponent_Accessory:
                    if (Pawn.m_aoAccessories.Length <= m_nAccessory)
                    {
                        Pawn.m_aoAccessories.Length = m_nAccessory + 1;
                    }
                    SetComponentMesh(Pawn, Pawn.m_aoAccessories[m_nAccessory], m_bCreateComponent);
                    break;
                default:
            }
            UpdateBoneMap(Pawn);
        }
    }
}
public function SkeletalMeshComponent CreateComponent(BioPawn InPawn)
{
    local SkeletalMeshComponent NewCmpt;
    
    NewCmpt = new (InPawn) Class'SkeletalMeshComponent';
    NewCmpt.MinAutoLODLevel = 0;
    NewCmpt.bTransformFromAnimParent = 1;
    NewCmpt.bUseOnePassLightingOnTranslucency = TRUE;
    NewCmpt.SetParentAnimComponent(InPawn.Mesh);
    NewCmpt.SetShadowParent(InPawn.Mesh);
    NewCmpt.SetLightEnvironment(InPawn.LightEnvironment);
    InPawn.AttachComponent(NewCmpt);
    return NewCmpt;
}
public function SetComponentMesh(BioPawn InPawn, SkeletalMeshComponent InComponent, bool bCreateCmpt)
{
    local MaterialInstanceConstant MIC;
    local int idx;
    
    if (InComponent == None && bCreateCmpt)
    {
        InComponent = CreateComponent(InPawn);
    }
    if (InComponent == None)
    {
        return;
    }
    for (idx = 0; idx < InComponent.GetNumElements(); ++idx)
    {
        InComponent.SetMaterial(idx, None);
    }
    InComponent.SetSkeletalMesh(m_oMesh, m_bPreserveAnimation);
    if (InComponent.SkeletalMesh != None)
    {
        for (idx = 0; idx < InComponent.SkeletalMesh.Materials.Length; ++idx)
        {
            MIC = new (InComponent) Class'MaterialInstanceConstant';
            MIC.SetParent(InComponent.SkeletalMesh.Materials[idx]);
            if (m_aoMaterials.Length != 0 && m_aoMaterials[idx] != None)
            {
                MIC.SetParent(m_aoMaterials[idx]);
            }
            ApplyBasicOverrides(InPawn, MIC);
            InComponent.SetMaterial(idx, MIC);
        }
    }
}
public function ApplyBasicOverrides(BioPawn InPawn, MaterialInstanceConstant InMaterial)
{
    local BioPawnBehavior Behavior;
    local BioInterface_Appearance_Pawn AppearanceType;
    local BioMorphFace Morph;
    local BioMaterialOverride Overrides;
    local ColorParameter Param;
    
    if (SFXPawn(InPawn) != None)
    {
        Behavior = BioPawnBehavior(InPawn.oBioComponent);
        if (Behavior != None)
        {
            if (BioInterface_Appearance_Pawn(Behavior.m_oAppearanceType) != None)
            {
                Overrides = BioInterface_Appearance_Pawn(Behavior.m_oAppearanceType).m_pMaterialParameters;
            }
        }
    }
    else
    {
        Morph = InPawn.MorphHead;
        if (Morph == None || Morph.m_oMaterialOverrides == None)
        {
            Morph = BioPawnType(InPawn.ActorType).m_oMorphFace;
        }
        if (Morph != None)
        {
            Overrides = Morph.m_oMaterialOverrides;
        }
    }
    if (Overrides == None)
    {
        return;
    }
    foreach Overrides.m_aColorOverrides(Param, )
    {
        if (Param.nName == 'SkinTone' || Param.nName == 'HED_Hair_Colour_Vector')
        {
            InMaterial.SetVectorParameterValue(Param.nName, Param.cValue);
        }
    }
}
public function UpdateBoneMap(BioPawn InPawn)
{
    local SkeletalMeshComponent MeshCmpt;
    
    foreach InPawn.ComponentList(Class'SkeletalMeshComponent', MeshCmpt)
    {
        MeshCmpt.MinAutoLODLevel = 0;
        if (MeshCmpt != None && MeshCmpt != InPawn.Mesh)
        {
            MeshCmpt.UpdateParentBoneMap();
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
                     }, 
                     {
                      LinkedVariables = (), 
                      LinkDesc = "Mesh", 
                      ExpectedType = Class'SeqVar_Object', 
                      LinkVar = 'None', 
                      PropertyName = 'm_oMesh', 
                      CachedProperty = None, 
                      MinVars = 1, 
                      MaxVars = 1, 
                      bWriteable = FALSE, 
                      bModifiesLinkedObject = FALSE, 
                      bAllowAnyType = FALSE
                     }
                    )
}