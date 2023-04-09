locals {
    my_ip = jsondecode(data.http.my_ip.body)["ip"]
    public_key = file(var.public_key_file)
}