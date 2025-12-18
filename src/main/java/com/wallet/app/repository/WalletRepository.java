package com.wallet.app.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.wallet.app.model.Wallet;

@Repository
public interface WalletRepository extends JpaRepository<Wallet, String>
{
    
     Optional<Wallet> findByWalletId(String walletId);

     boolean existsBywalletId(String walletId);
}
