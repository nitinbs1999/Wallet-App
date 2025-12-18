package com.wallet.app.service;

import com.wallet.app.dto.TransactionResponse;
import com.wallet.app.dto.WalletRequest;
import com.wallet.app.dto.WalletResponse;
import com.wallet.app.model.Transaction;

public interface UserService 
{

   WalletResponse create(WalletRequest request); 
   int getBalance(String walletId);
   TransactionResponse deposit(String walletId, int amount);
   TransactionResponse withdraw(String walletId, int amount);

}
