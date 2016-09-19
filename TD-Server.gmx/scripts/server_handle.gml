///server_handle()
var bf  = async_load[? "buffer"];
var cmd = buffer_read(bf,buffer_u16);
var pos = ds_list_find_index(client[data.ip],async_load[? "ip"]);
switch(cmd)
{
    case command.login:
        buffer_seek(buff,buffer_seek_start,0);
        buffer_write(buff,buffer_u16,command.login);
        var name = buffer_read(bf,buffer_string);
        var pass = buffer_read(bf,buffer_string);
        if file_exists("players.data")
        {
            var map = ds_map_secure_load("players.data");
            if ds_map_exists(map,name)
            {
                var dat = ds_map_create();
                ds_map_read(dat,map[? name]);
                var salt = dat[? "salt"];
                if sha1_string_unicode(pass+salt) == dat[? "password"]
                {
                    ds_list_replace(client[data.id],pos,dat[? "id"]);
                    ds_list_replace(client[data.username],pos,name);
                    buffer_write(buff,buffer_bool,true);
                }
                else buffer_write(buff,buffer_bool,false);
                ds_map_destroy(dat);
            }
            else buffer_write(buff,buffer_bool,false);
            ds_map_destroy(map);
        }
        else buffer_write(buff,buffer_bool,false);
        buffer_write(buff,buffer_string,name);
        network_send_packet(async_load[? "id"],buff,buffer_tell(buff));
        break;
    case command.register:
        buffer_seek(buff,buffer_seek_start,0);
        buffer_write(buff,buffer_u16,command.register);
        var name = buffer_read(bf,buffer_string);
        var pass = buffer_read(bf,buffer_string);
        if file_exists("players.data") var map = ds_map_secure_load("players.data");
        else var map = ds_map_create();
        if !ds_map_exists(map,name)
        {
            var dat             = ds_map_create();
            var salt            = generate_string(32);
            dat[? "password"]   = sha1_string_unicode(pass+salt);
            dat[? "salt"]       = salt;
            dat[? "id"]         = ds_map_size(map)+10000;
            map[? name]         = ds_map_write(dat);
            ds_list_replace(client[data.id],pos,dat[? "id"]);
            ds_list_replace(client[data.username],pos,name);
            buffer_write(buff,buffer_bool,true);
            ds_map_destroy(dat);
        }
        else buffer_write(buff,buffer_bool,false);
        buffer_write(buff,buffer_string,name);
        ds_map_secure_save(map,"players.data");
        network_send_packet(async_load[? "id"],buff,buffer_tell(buff));
        ds_map_destroy(map);
        break;
}
