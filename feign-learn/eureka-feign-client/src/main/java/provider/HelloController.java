package provider;

import api.HelloService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author zhangchenghao
 */
@RestController
public class HelloController implements HelloService {

    @Value("${server.port}")
    private String serverPort;

    @Override
    public String hello(@RequestParam(value = "name", required = false) String name) {
        return "from server port:" + serverPort + ",hello:" + name;
    }
}
