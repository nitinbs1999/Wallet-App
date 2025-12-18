package com.wallet.app.controller;

import static org.mockito.ArgumentMatchers.any;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallet.app.dto.TransactionRequest;
import com.wallet.app.dto.TransactionResponse;
import com.wallet.app.dto.WalletRequest;
import com.wallet.app.dto.WalletResponse;
import com.wallet.app.model.TransactionType;
import com.wallet.app.service.UserService;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(WalletController.class)
public class WalletControllerTest {

    
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private UserService userService;

    @Test
    void createWallet() throws Exception{

          WalletRequest request=new WalletRequest();
          request.setBalance(100);
          request.setOwnerName("Nitin");
          request.setWalletId("snitin6528");
          
          WalletResponse mockResponse=WalletResponse.builder()
                                                    .balance(0)
                                                    .ownerName("Nitin")
                                                    .walletId("snitin6528")
                                                    .build();

        Mockito.when(userService.create(any(WalletRequest.class))).thenReturn(mockResponse);
        mockMvc.perform(post("/api/v1/wallets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.walletId").value("snitin6528"));
    }

    @Test
    void getBalance() throws Exception
    {
          String walletId = "snitin6528";
          int mockBalance = 500;
         // String owner= "Nitin";

          Mockito.when(userService.getBalance(walletId)).thenReturn(mockBalance);

          mockMvc.perform(get("/api/v1/wallets/{walletId}/balance", "snitin6528")
                    .contentType(MediaType.APPLICATION_JSON))
                     .andExpect(status().isOk())
                       .andExpect(content().string("500"));
    }
    @Test
    void deposit() throws Exception{
           
        String walletId="snitin6528";
        TransactionRequest request=new TransactionRequest(TransactionType.DEPOSIT, 500);
        TransactionResponse mockResponse=new TransactionResponse("UTR001", walletId, TransactionType.DEPOSIT, 500, 500);
        Mockito.when(userService.deposit(walletId, 500)).thenReturn(mockResponse);
         mockMvc.perform(post("/api/v1/wallets/{walletId}/deposit", walletId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.walletId").value("snitin6528"))
                .andExpect(jsonPath("$.transactionId").value("UTR001"))
                .andExpect(jsonPath("$.balanceAfter").value(500))
                .andExpect(jsonPath("$.type").value("DEPOSIT"));
    }


    @Test
    void withdraw() throws Exception
    {

        String walletId="snitin6528";
        TransactionRequest request=new TransactionRequest(TransactionType.WITHDRAW, 500);
        TransactionResponse mockResponse=new TransactionResponse("UTR001", walletId, TransactionType.WITHDRAW, 500, 0);
        Mockito.when(userService.withdraw(walletId, 500)).thenReturn(mockResponse);
         mockMvc.perform(post("/api/v1/wallets/{walletId}/withdraw", walletId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.walletId").value("snitin6528"))
                .andExpect(jsonPath("$.transactionId").value("UTR001"))
                .andExpect(jsonPath("$.balanceAfter").value(0))
                .andExpect(jsonPath("$.type").value("WITHDRAW"));
                
    }

    
}
