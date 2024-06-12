import salt.utils.http
import json

class ConsoleHelper:
    def register_service(
            env,
            vendor,
            region,
            service_name,
            ip,
            port,
            tags=None,
            check_tcp=None,
            interval=None,
            timeout=None
        ):
        service_data = {
            "ENV": id,
            "CSP": vendor,
            "Region": region,
            "Service": service_name,
        }

        if tags:
            service_data["Tags"] = tags

        if check_tcp:
            service_data["Check"] = {
                "TCP": f"{ip}:{port}",
            }

            if interval:
                service_data["Check"]["Interval"] = interval

            if timeout:
                service_data["Check"]["Timeout"] = timeout

        url = "http://localhost:8500/v1/agent/service/register"
        data = json.dumps(service_data)

        response = salt.utils.http.query(
            url,
            method='POST',
            data=data,
            decode=True,
            status=True,
            header_dict={
                'Content-Type': 'application/json',
            },
        )

        if response['status'] == 200:
            return True
        else:
            return False
        
    def remove_service(id):
        url = f"http://localhost:8500/v1/agent/service/deregister/{id}"
        response = salt.utils.http.query(
            url,
            method='PUT',
            decode=True,
            status=True,
        )
        if response['status'] == 200:
            return True
        else:
            return False
    