import { Component, OnInit, HostListener } from '@angular/core';
import { CartService } from 'src/app/core/mock/cart.service';
import { CartProduct } from 'src/app/core/data/cart-product';
import { Product } from 'src/app/core/data/product';
import { PaymentService } from 'src/app/core/mock/payment.service';
import { AddressService } from 'src/app/core/mock/address.service';
import { Router } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';
import { routerNgProbeToken } from '@angular/router/src/router_module';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-payment',
  templateUrl: './payment.component.html',
  styleUrls: ['./payment.component.css']
})
export class PaymentComponent implements OnInit {

  handler:any;
  cartData;
  productData:Product[];
  price={total:"",discount:"",net:""};
  selectedOption;
  lastSelectedOption;
  shippingOpitons=new Array();
  count;
  allProduct:CartProduct[]=new Array();

  constructor(private _cartService:CartService,
              private _addressService:AddressService,
              private _router:Router,
              private _paymentService:PaymentService,
              private _authService:AuthService,
              private _dataExchangeService:DataExchangeService) { }

  ngOnInit() {
    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }

    this._cartService.getCartProducts()
    .subscribe(
      res=>{
        this.cartData=res[0]; 
        this.productData=res[1];
        let size;
        let total:number,discount:number,net:number;
        total=discount=net=0;
        for(let i=0;i<this.cartData.length;i++){
          for(let j=0;j<this.productData.length;j++){
            if(this.cartData[i].product_id==this.productData[j].product_id){
              size=JSON.parse(this.cartData[i].attributes);
              let product:CartProduct={
                item_id:this.cartData[i].item_id,
                name:this.productData[j].name,
                price:this.productData[j].price.toString(),
                discounted_price:this.productData[j].discounted_price.toString(),
                actual_price:this.productData[j].price,
                actual_discount:this.productData[j].discounted_price,
                quantity:this.cartData[i].quantity,
                size:size.Size,
                color:size.Color,
                image:this.productData[j].image
              };
              total=total+this.productData[j].price+this.productData[j].discounted_price;
              discount=discount+this.productData[j].discounted_price;
              this.allProduct.push(product);
            }
          }
        }
        this.count=this.allProduct.length;
        net=total-discount;
        this.price={
          total:total.toFixed(2).toString(),
          discount:discount.toFixed(2).toString(),
          net:net.toFixed(2).toString()
        }
      }
    )
    this._addressService.getAddress()
    .subscribe(
      res=>{
        this._addressService.getShippingOptions()
        .subscribe(
          response=>{
            this.shippingOpitons=response;
            this.shippingOpitons=this.shippingOpitons.filter(options=>options.shipping_region_id==res[0].shipping_region_id)
            this.selectedOption=this.shippingOpitons[0].shipping_id;
            this.price.net=Number(this.price.net) +this.shippingOpitons[0].shipping_cost;
            this.lastSelectedOption=this.selectedOption;
          }
        )
      }
    )
  }
  callMethod(){
    console.log("dsf");
  }

  openCheckout(){
    this.handler = (<any>window).StripeCheckout.configure({
      key: 'pk_test_XfbeMez71536uyZV10cMz4ZI00rFqtzMPs',
      locale: 'auto',
      token: token => {
        let paymentToken={
          stripeToken:token,
          amount:Number(this.price.net),
          shipping_id:this.selectedOption
        }
        console.log(paymentToken);
        this._paymentService.paymentcheckOut(paymentToken)
        .subscribe(
          res=>{
            this._dataExchangeService.changeCartData("added");
            this._router.navigate(['orders']);
          } 
        );
       }
     });

   this.handler.open({
      name: 'Payment',
      description: '',
      amount: Number(this.price.net)*100  
    });
  }
  shippingChange(){
    if(this.selectedOption!=this.lastSelectedOption){
      for(let i=0;i<this.shippingOpitons.length;i++){
        if(this.shippingOpitons[i].shipping_id==this.lastSelectedOption){
          this.price.net=(Number(this.price.net)-this.shippingOpitons[i].shipping_cost).toString();
        }
        if(this.shippingOpitons[i].shipping_id==this.selectedOption){
          this.price.net=(Number(this.price.net)+this.shippingOpitons[i].shipping_cost).toString();
        }
      }
      
      this.lastSelectedOption=this.selectedOption;
      this.price.net=Number(this.price.net).toFixed(2);
    }
  }
  clickBag(){
    this._router.navigate(['cart']);
  }
  clickAddress(){
    this._router.navigate(['address']);
  }

  @HostListener('window:popstate')
    onPopstate() {
      this.handler.close()
    }
}
