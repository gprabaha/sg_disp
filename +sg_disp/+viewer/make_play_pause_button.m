function [fig, play_pause_button] = make_play_pause_button(fig, params, callback_funcition)

position = params.play_pause_position;
size = params.play_pause_size;
play_pause_button = uicontrol('Parent', fig, ...
    'Style', 'togglebutton', ...
    'String', 'Play', ...
    'Units', 'normalized', ...
    'Position', [position size], ...
    'Callback', callback_funcition);  % Set callback function handle

end