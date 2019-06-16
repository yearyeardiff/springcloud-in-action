package com.zhang.eureka.controller;

import com.zhang.eureka.domain.Product;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
public class ProductController {

    @RequestMapping(value = "list", method = RequestMethod.GET)
    public List<Product> productList(){
        List<Product> list = new ArrayList<>();
        list.add(new Product(1, "dog"));
        list.add(new Product(2, "cat"));
        list.add(new Product(3, "pig"));
        return list;
    }
}
