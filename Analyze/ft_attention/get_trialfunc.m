function [trialfun] = get_trialfunc(subject,dfile)

switch subject
    case 'Bonner'
        switch dfile
            case 'face1'
                trialfun = @Bonner_face1_trialfun;
            case 'face2'
                trialfun = @Bonner_face2_trialfun;
            case 'scene1'
                trialfun = @Bonner_scene1_trialfun;
            case 'scene2'
                trialfun = @Bonner_scene2_trialfun;
            case 'scene3'
                trialfun = @Bonner_scene3_trialfun;
            case 'passive1'
                trialfun = @Bonner_passive1_trialfun;
            case 'passive2'
                trialfun = @Bonner_passive2_trialfun;
        end
end
    
