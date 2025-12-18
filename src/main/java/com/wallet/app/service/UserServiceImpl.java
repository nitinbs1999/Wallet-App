package com.wallet.app.service;


import java.util.UUID;

import org.springframework.stereotype.Service;

import com.wallet.app.dto.Status;
import com.wallet.app.dto.TransactionResponse;
import com.wallet.app.dto.WalletRequest;
import com.wallet.app.dto.WalletResponse;
import com.wallet.app.exception.InsufficientBalanceException;
import com.wallet.app.exception.WalletNotFoundException;
import com.wallet.app.model.Transaction;
import com.wallet.app.model.TransactionType;
import com.wallet.app.model.Wallet;
import com.wallet.app.repository.TransactionRepository;
import com.wallet.app.repository.WalletRepository;

import jakarta.transaction.Transactional;

@Service
public class UserServiceImpl implements UserService
{


 private final WalletRepository walletRepository;    
 private final TransactionRepository transactionRepository;

 public UserServiceImpl(WalletRepository walletRepository, TransactionRepository transactionRepository){
    this.walletRepository=walletRepository;
    this.transactionRepository=transactionRepository;
 }



    @Override
    public WalletResponse create(WalletRequest request) {
        // Check if wallet already exists
        if (walletRepository.findByWalletId(request.getWalletId()).isPresent()) {
            throw new com.wallet.app.exception.WalletAlreadyExistsException(
                "Wallet with ID '" + request.getWalletId() + "' already exists"
            );
        }

        Wallet wallet= Wallet.builder().walletId(request.getWalletId())
                       .balance(request.getBalance())
                       .owner(request.getOwnerName())
                       .build();
         //save this wallet
         walletRepository.save(wallet);
         WalletResponse response=WalletResponse.builder()
                                            .walletId(wallet.getWalletId())
                                            .balance(wallet.getBalance())
                                            .status(Status.ACTIVE)
                                             .ownerName(wallet.getOwner())
                                            .build();
        return response;
    }

    @Override
    public int getBalance(String walletId) {

        //check walletId exists or not
        
        Wallet wallet=walletRepository.findByWalletId(walletId).orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
        
        return wallet.getBalance();
    }

    @Override
    @Transactional   //for consistency if any opreation fail it will roll back the changes.
    public TransactionResponse deposit(String walletId, int amount) {
        // TODO Auto-generated method stub
        Wallet wallet=walletRepository.findByWalletId(walletId).orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
        int balance_after=wallet.getBalance()+amount;
         wallet.setBalance(balance_after);
         walletRepository.save(wallet);
         Transaction transaction=Transaction.builder().transactionId(UUID.randomUUID().toString())
                                  .amount(amount)
                                  .balanceAfter(balance_after)
                                  .type(TransactionType.DEPOSIT)
                                  .wallet(wallet)
                                  .build();
        //save this transaction
                   transactionRepository.save(transaction);
        //map this to transaction response and return
        return maptoDto(transaction);
    }

    @Override
    @Transactional
    public TransactionResponse withdraw(String walletId, int amount) {

        Wallet wallet=walletRepository.findByWalletId(walletId).orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
        int balance_after=wallet.getBalance()-amount;
        if(balance_after<0){
            throw new InsufficientBalanceException("Insufficient balance in account!");
        }
         wallet.setBalance(balance_after);
         walletRepository.save(wallet);
         Transaction transaction=Transaction.builder().transactionId(UUID.randomUUID().toString())
                                  .amount(amount)
                                  .balanceAfter(balance_after)
                                  .type(TransactionType.WITHDRAW)
                                  .wallet(wallet)
                                  .build();
         //save this transaction
         transactionRepository.save(transaction);
         //map this to transactionresponse;
         return maptoDto(transaction); 
      }

    public TransactionResponse maptoDto(Transaction transaction)
    {
        TransactionResponse response=TransactionResponse.builder()
                                                        .transactionId(transaction.getTransactionId())
                                                        .walletId(transaction.getWallet().getWalletId())
                                                        .amount(transaction.getAmount())
                                                        .balanceAfter(transaction.getBalanceAfter())
                                                        .type(transaction.getType())
                                                        .build();
                            return response;
    }
    
}
