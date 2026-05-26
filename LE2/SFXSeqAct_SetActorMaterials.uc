Class SFXSeqAct_SetActorMaterials extends SequenceAction;

enum FActorComponent
{
    ActorComponent_Mesh,
    ActorComponent_Head,
    ActorComponent_Hair,
};

var(SFXSeqAct_SetActorMaterials) FActorComponent m_eActorComponent;
var(SFXSeqAct_SetActorMaterials) array<MaterialInterface> m_aoMaterials;

public function Activated()
{
    local Object ChkObject;
    local SkeletalMeshActor SMA;
    
    foreach Targets(ChkObject, )
    {
        SMA = SFXSkeletalMeshActor(ChkObject);
        if (SMA != None)
        {
            switch (m_eActorComponent)
            {
                case FActorComponent.ActorComponent_Mesh:
                    SetComponentMaterials(SMA, SMA.SkeletalMeshComponent);
                    break;
                case FActorComponent.ActorComponent_Head:
                    SetComponentMaterials(SMA, SFXSkeletalMeshActor(SMA).HeadMesh);
                    break;
                case FActorComponent.ActorComponent_Hair:
                    SetComponentMaterials(SMA, SFXSkeletalMeshActor(SMA).HairMesh);
                    break;
                default:
            }
            continue;
        }
        else
        {
            SMA = SFXSkeletalMeshActorMAT(ChkObject);
            if (SMA != None)
            {
                switch (m_eActorComponent)
                {
                    case FActorComponent.ActorComponent_Mesh:
                        SetComponentMaterials(SMA, SMA.SkeletalMeshComponent);
                        break;
                    case FActorComponent.ActorComponent_Head:
                        SetComponentMaterials(SMA, SFXSkeletalMeshActorMAT(SMA).HeadMesh);
                        break;
                    case FActorComponent.ActorComponent_Hair:
                        SetComponentMaterials(SMA, SFXSkeletalMeshActorMAT(SMA).HairMesh);
                        break;
                    default:
                }
                continue;
            }
            else
            {
                SMA = SkeletalMeshActor(ChkObject);
                if (SMA != None)
                {
                    SetComponentMaterials(SMA, SMA.SkeletalMeshComponent);
                }
            }
        }
    }
}
public function SetComponentMaterials(Actor InActor, SkeletalMeshComponent InComponent)
{
    local MaterialInstanceConstant MIC;
    local int idx;
    
    if (InComponent == None)
    {
        return;
    }
    if (InComponent != None)
    {
        for (idx = 0; idx < InComponent.SkeletalMesh.Materials.Length; ++idx)
        {
            if (m_aoMaterials.Length > 0 && m_aoMaterials[idx] != None)
            {
                MIC = new (InComponent) Class'MaterialInstanceConstant';
                MIC.SetParent(m_aoMaterials[idx]);
                ApplyBasicOverrides(InActor, MIC);
                InComponent.SetMaterial(idx, MIC);
            }
        }
    }
}
public function ApplyBasicOverrides(Actor InActor, MaterialInstanceConstant InMaterial)
{
    local BioMorphFace Morph;
    local ColorParameter Param;
    
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
        Morph = BioPawnType(InActor.ActorType).m_oMorphFace;
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
                     }
                    )
}