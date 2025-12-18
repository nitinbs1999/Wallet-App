package com.wallet.app.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import lombok.*;

@Entity
@Table(name = "wallets")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED) // REQUIRED by JPA
@AllArgsConstructor
@Builder
public class Wallet 
{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, unique = true)
    private String walletId;
    @Column(nullable = false)
    private int balance;
    @Column(nullable = false)
    private String owner;    
    @Version  // this is for for optimistic locking when multiple threads acess db 
    private Long version;
}
