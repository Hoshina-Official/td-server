///generate_string(length)
randomize();
var len = argument0;
var str = "";
repeat(len)
{
    str += chr(choose(irandom_range(17,26),irandom_range(34,59),irandom_range(66,91)));
}
return str;