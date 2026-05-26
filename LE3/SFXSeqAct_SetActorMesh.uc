Class SFXSeqAct_SetActorMesh extends SequenceAction;

enum EActorComponent
{
    ActorComponent_Mesh,
    ActorComponent_Head,
    ActorComponent_Hair,
    ActorComponent_Headgear,
};

var(SFXSeqAct_SetActorMesh) EActorComponent m_eActorComponent;
var(SFXSeqAct_SetActorMesh) SkeletalMesh m_oMesh;
var(SFXSeqAct_SetActorMesh) array<MaterialInterface> m_aoMaterials;
var(SFXSeqAct_SetActorMesh) bool m_bPreserveAnimation;

public function Activated()
{
    local Object ChkObject;
    local SFXStuntActor SA;
    local SkeletalMeshActor SMA;
    
    foreach Targets(ChkObject, )
    {
        SA = SFXStuntActor(ChkObject);
        if (SA != None)
        {
            switch (m_eActorComponent)
            {
                case EActorComponent.ActorComponent_Mesh:
                    SetComponentMesh(SA, SA.BodyMesh);
                    break;
                case EActorComponent.ActorComponent_Head:
                    SetComponentMesh(SA, SA.HeadMesh);
                    break;
                case EActorComponent.ActorComponent_Hair:
                    SetComponentMesh(SA, SA.HairMesh);
                    break;
                case EActorComponent.ActorComponent_Headgear:
                    SetComponentMesh(SA, SA.HeadGearMesh);
                    break;
                default:
            }
            UpdateBoneMap(SA);
            continue;
        }
        SMA = SFXSkeletalMeshActor(ChkObject);
        if (SMA != None)
        {
            switch (m_eActorComponent)
            {
                case EActorComponent.ActorComponent_Mesh:
                    SetComponentMesh(SMA, SMA.SkeletalMeshComponent);
                    break;
                case EActorComponent.ActorComponent_Head:
                    SetComponentMesh(SMA, SFXSkeletalMeshActorMAT(SMA).HeadMesh);
                    break;
                case EActorComponent.ActorComponent_Hair:
                    SetComponentMesh(SMA, SFXSkeletalMeshActor(SMA).HairMesh);
                    break;
                case EActorComponent.ActorComponent_Headgear:
                    SetComponentMesh(SMA, SFXSkeletalMeshActor(SMA).HeadGearMesh);
                    break;
                default:
            }
            UpdateBoneMap(SMA);
            continue;
        }
        else
        {
            SMA = SFXSkeletalMeshActorMAT(ChkObject);
            if (SMA != None)
            {
                switch (m_eActorComponent)
                {
                    case EActorComponent.ActorComponent_Mesh:
                        SetComponentMesh(SMA, SMA.SkeletalMeshComponent);
                        break;
                    case EActorComponent.ActorComponent_Head:
                        SetComponentMesh(SMA, SFXSkeletalMeshActorMAT(SMA).HeadMesh);
                        break;
                    case EActorComponent.ActorComponent_Hair:
                        SetComponentMesh(SMA, SFXSkeletalMeshActorMAT(SMA).HairMesh);
                        break;
                    default:
                }
                UpdateBoneMap(SMA);
                continue;
            }
            else
            {
                SMA = SkeletalMeshActor(ChkObject);
                if (SMA != None)
                {
                    SetComponentMesh(SMA, SMA.SkeletalMeshComponent);
                    UpdateBoneMap(SMA);
                }
            }
        }
    }
}
public function SetComponentMesh(Actor InActor, SkeletalMeshComponent InComponent)
{
    local MaterialInstanceConstant MIC;
    local int idx;
    
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
            if (m_aoMaterials.Length > 0 && m_aoMaterials[idx] != None)
            {
                MIC.SetParent(m_aoMaterials[idx]);
            }
            ApplyBasicOverrides(InActor, MIC);
            InComponent.SetMaterial(idx, MIC);
        }
    }
}
public function ApplyBasicOverrides(Actor InActor, MaterialInstanceConstant InMaterial)
{
    local BioMorphFace Morph;
    local ColorParameter Param;
    
    if (SFXStuntActor(InActor) != None)
    {
        Morph = SFXStuntActor(InActor).MorphHead;
    }
    if (SFXSkeletalMeshActor(InActor) != None)
    {
        Morph = SFXSkeletalMeshActor(InActor).MorphHead;
    }
    if (SFXSkeletalMeshActorMAT(InActor) != None)
    {
        Morph = SFXSkeletalMeshActorMAT(InActor).MorphHead;
    }
    if (Morph == None || Morph.m_oMaterialOverrides == None)
    {
        return;
    }
    foreach Morph.m_oMaterialOverrides.m_aColorOverrides(Param, )
    {
        if (Param.nName == 'SkinTone' || Param.nName == 'HED_Hair_Colour_Vector')
        {
            InMaterial.SetVectorParameterValue(Param.nName, Param.cValue);
        }
    }
}
public function UpdateBoneMap(Actor InActor)
{
    local SkeletalMeshComponent MeshCmpt;
    local int idx;
    
    foreach InActor.ComponentList(Class'SkeletalMeshComponent', MeshCmpt)
    {
        if (MeshCmpt != None)
        {
            if (SFXStuntActor(InActor) != None && SFXStuntActor(InActor).BodyMesh != MeshCmpt)
            {
                MeshCmpt.UpdateParentBoneMap();
            }
            if (SkeletalMeshActor(InActor) != None && MeshCmpt != SkeletalMeshActor(InActor).SkeletalMeshComponent)
            {
                MeshCmpt.UpdateParentBoneMap();
            }
        }
    }
}

//class default properties can be edited in the Properties tab for the class's Default__ object.
defaultproperties
{
    bCallHandler = FALSE
    VariableLinks = ({
                      LinkedVariables = (), 
                      LinkDesc = "Actor", 
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