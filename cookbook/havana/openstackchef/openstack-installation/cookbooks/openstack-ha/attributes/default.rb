default['ha_type'] = 'haproxy'

default["ha"]["available_services"] = {
    "keystone" => [
        {
          "role" => "keystone",
          "namespace" => "keystone",
          "service" => "admin-api",
          "service_type" => "identity",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        },
        {
          "role" => "keystone",
          "namespace" => "keystone",
          "service" => "service-api",
          "service_type" => "identity",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        }
    ],
    "nova_api" => [
        {
          "role" => "nova-api",
          "namespace" => "nova",
          "service" => "api",
          "service_type" => "compute",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        }
    ],
    "ec2_api" => [
        {
          "role" => "ec2-api",
          "namespace" => "ec2",
          "service" => "api",
          "service_type" => "ec2",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => []
        },
        {
          "role" => "ec2-api",
          "namespace" => "ec2",
          "service" => "admin-api",
          "service_type" => "ec2",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => []
        }
    ],
    "glance" => [
        {
          "role" => "glance",
          "namespace" => "glance",
          "service" => "api",
          "service_type" => "image",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        },
        {
          "role" => "glance",
          "namespace" => "glance",
          "service" => "registry",
          "service_type" => "image",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => []
        }
    ],
    "cinder" => [
        {
          "role" => "cinder-api",
          "namespace" => "cinder",
          "service" => "api",
          "service_type" => "volume",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        }
    ],
    "quantum" => [
        {
          "role" => "quantum-server",
          "namespace" => "quantum",
          "service" => "server",
          "service_type" => "network",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        }
    ],
    "other" => [
        {
          "role" => "swift-proxy-server",
          "namespace" => "swift",
          "service" => "proxy",
          "service_type" => "object-store",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => []
        },
        {
          "role" => "nova-vncproxy",
          "namespace" => "nova",
          "service" => "novnc-proxy",
          "service_type" => "compute",
          "lb_mode" => "tcp",
          "lb_algorithm" => "source",
          "lb_options" => []
        },
        {
          "role" => "nova-vncproxy",
          "namespace" => "nova",
          "service" => "xvpvnc-proxy",
          "service_type" => "compute",
          "lb_mode" => "tcp",
          "lb_algorithm" => "source",
          "lb_options" => []
        },
        {
          "role" => "horizon-server",
          "namespace" => "horizon",
          "service" => "dash",
          "service_type" => "dash",
          "lb_mode" => "http",
          "lb_algorithm" => "roundrobin",
          "lb_options" => ["forwardfor", "httpchk", "httplog"]
        },
        {
          "role" => "horizon-server",
          "namespace" => "horizon",
          "service" => "dash_ssl",
          "service_type" => "dash",
          "lb_mode" => "tcp",
          "lb_algorithm" => "source",
          "lb_options" => []
        }
    ]
}
default['ha']['swift-only'] = false
