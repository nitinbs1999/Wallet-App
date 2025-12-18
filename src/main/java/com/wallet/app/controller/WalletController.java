package com.wallet.app.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.wallet.app.dto.TransactionRequest;
import com.wallet.app.dto.TransactionResponse;
import com.wallet.app.dto.WalletRequest;
import com.wallet.app.dto.WalletResponse;
import com.wallet.app.model.Transaction;
import com.wallet.app.service.UserService;

@RestController
@RequestMapping("/api/v1/wallets")
public class WalletController 
{
    private final  UserService  userService;

    public WalletController(UserService userService){
        this.userService=userService;
    }
    //create a wallet
    @PostMapping
    public ResponseEntity<WalletResponse> CreateWallet( @RequestBody WalletRequest request)
    {
        WalletResponse response=userService.create(request);
        return  ResponseEntity.ok(response);
    }
    //get balance
    @GetMapping("/{walletId}/balance")
    public ResponseEntity<Integer> GetBalance(@PathVariable String walletId)
    {
        int balance=userService.getBalance(walletId);
        return ResponseEntity.ok(balance);
    }
    @PostMapping("/{walletId}/deposit")
    public ResponseEntity<TransactionResponse> Deposit(@PathVariable String walletId,@RequestBody TransactionRequest request){

         TransactionResponse transaction=userService.deposit(walletId, request.getAmount());
         return ResponseEntity.ok(transaction);
    }

    @PostMapping("/{walletId}/withdraw")
    public ResponseEntity<TransactionResponse> Withdraw(@PathVariable String walletId,@RequestBody TransactionRequest request){

      TransactionResponse transaction=userService.withdraw(walletId, request.getAmount());
      return ResponseEntity.ok(transaction);
    }
    
}
