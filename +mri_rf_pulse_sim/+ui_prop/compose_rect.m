function out = compose_rect(innner_rect,outer_rect)
% outer_rect : position of the "container"
% inner_rect : relative position in the "container"
% out        : position of the object in the same reference as the "container"
out = [innner_rect(1)*outer_rect(3)+outer_rect(1) innner_rect(2)*outer_rect(4)+outer_rect(2) innner_rect(3)*outer_rect(3) innner_rect(4)*outer_rect(4)];
end % fcn
