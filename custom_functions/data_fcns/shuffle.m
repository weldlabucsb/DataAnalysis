function shuffled_vec = shuffle(vec)
% SHUFFLE randomizes the order of elements in the input vector.
    shuffled_vec = vec(randperm(length(vec)));
end