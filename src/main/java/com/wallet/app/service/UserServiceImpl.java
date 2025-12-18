package com.wallet.app.service;

import java.lang.module.ResolutionException;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.wallet.app.dto.Status;
import com.wallet.app.dto.TransactionResponse;
import com.wallet.app.dto.WalletRequest;
import com.wallet.app.dto.WalletResponse;
import com.wallet.app.model.Transaction;
import com.wallet.app.model.TransactionType;
import com.wallet.app.model.Wallet;
import com.wallet.app.repository.TransactionRepository;
import com.wallet.app.repository.UserRepository;
import com.wallet.app.repository.WalletRepository;

@Service
public class UserServiceImpl implements UserService
{


 private final WalletRepository walletRepository;    
 private final TransactionRepository transactionRepository;


    @Override
    public WalletResponse create(WalletRequest request) {
        // TODO Auto-generated method stub
        //if wallet id already exist
       if(walletRepository.existsBywalletId(request.getWalletId())){
            throw new WalletFoundException("wallet already exists");
       }

        Wallet wallet= Wallet.builder().wallet_id(request.getWalletId())
                       .balance(request.getBalance())
                       .owner(request.getOwnerName())
                       .build();
         //save this wallet
         walletRepository.save(wallet);
         WalletResponse response=WalletResponse.builder()
                                            .walletId(wallet.getWallet_id())
                                            .balance(wallet.getBalance())
                                            .status(Status.ACTIVE)
                                            .build();
        return response;
    }

    @Override
    public int getBalance(String walletId) {
        
        return walletRepository.findByWalletId(walletId).getBalance();
           
    }

    @Override
    public TransactionResponse deposit(String walletId, int amount) {
        // TODO Auto-generated method stub
         Wallet wallet=walletRepository.findByWalletId(walletId);
         int balance_after=wallet.getBalance()+amount;
         wallet.setBalance(balance_after);
         walletRepository.save(wallet);
         Transaction transaction=Transaction.builder().transaction_id("123")
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
    public TransactionResponse withdraw(String walletId, int amount) {

         Wallet wallet=walletRepository.findByWalletId(walletId);
         int balance_after=wallet.getBalance()-amount;
         wallet.setBalance(balance_after);
         walletRepository.save(wallet);
         Transaction transaction=Transaction.builder().transaction_id("123")
                                  .amount(amount)
                                  .balanceAfter(balance_after)
                                  .type(TransactionType.DEPOSIT)
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
                                                        .transactionId(transaction.getTransaction_id())
                                                        .walletId(transaction.getWallet().getWallet_id())
                                                        .amount(transaction.getAmount())
                                                        .balanceAfter(transaction.getBalanceAfter())
                                                        .type(transaction.getType())
                                                        .build();
                            return response;
    }
    
}
