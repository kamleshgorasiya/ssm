import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { HttpErrorResponse } from '@angular/common/http';
import { Cart } from 'src/app/core/data/cart';
import { ProductService } from 'src/app/core/mock/product.service';
import { CartService } from 'src/app/core/mock/cart.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  errorText="";
  user:any={};
  constructor(private route:ActivatedRoute,
              private _authService:AuthService,
              private _router:Router,
              private dataService:DataExchangeService,
              private _productService:ProductService,
              private _cartService:CartService) { 
    
  }

  ngOnInit() {
  }

  loginUser(){
    this._authService.loginUser(this.user)
    .subscribe(
      res=>{
        localStorage.setItem("token",res.token);
        this._authService.getUser()
        .subscribe(
          res=>{
             this.dataService.changeUserName(res[0])
             this.addCartData();
             this._router.navigate(['']);
          },
        )
        
      },
      err=>{
        this.errorText=err.error;
      }
    )
  }

  addCartData(){
    let data=localStorage.getItem("cart");
    try{
      let cart:Cart[];
      cart=JSON.parse(data);
      this._cartService.addLocalBags(cart)
      .subscribe(
        res=>{
          localStorage.removeItem("cart");
          this.dataService.changeCartData("added");
        }
      )
    } catch(e){
    }
  }
}
