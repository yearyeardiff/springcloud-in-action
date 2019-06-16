package consumer;

import api.HelloService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author zhangchenghao
 */
@RestController
public class TestController {

    @Autowired
    private HelloService helloServiceClient;

    @GetMapping("/test")
    public String test(String name) {
        return helloServiceClient.hello(name);
    }

}
