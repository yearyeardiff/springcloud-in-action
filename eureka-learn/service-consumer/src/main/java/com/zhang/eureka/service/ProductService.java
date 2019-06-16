package com.zhang.eureka.service;

import com.zhang.eureka.domain.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.loadbalancer.LoadBalancerClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class ProductService {

    @Autowired
    private LoadBalancerClient loadBalancerClient;

    public List<Product> productList(){
        ServiceInstance si = loadBalancerClient.choose("eureka-provider");

        StringBuilder sb = new StringBuilder("");
        sb.append("http://");
        sb.append(si.getHost());
        sb.append(":");
        sb.append(si.getPort());
        sb.append("/list");
        System.out.println(sb.toString());


        RestTemplate restTemplate = new RestTemplate();
        ParameterizedTypeReference<List<Product>> typeReference =
                new ParameterizedTypeReference<List<Product>>() {
                };

        ResponseEntity<List<Product>> resp = restTemplate.exchange(sb.toString(), HttpMethod.GET, null, typeReference);
        List<Product> productList = resp.getBody();
        return productList;

    }
}
