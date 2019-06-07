import { Component, OnInit, HostListener } from '@angular/core';
import { CartService } from 'src/app/core/mock/cart.service';
import { CartProduct } from 'src/app/core/data/cart-product';
import { Product } from 'src/app/core/data/product';
import { PaymentService } from 'src/app/core/mock/payment.service';
import { AddressService } from 'src/app/core/mock/address.service';
import { Router } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-payment',
  templateUrl: './payment.component.html',
  styleUrls: ['./payment.component.css']
})
export class PaymentComponent implements OnInit {

  allProduct:CartProduct[]=new Array();
  handler:any;
  productData=new Array();
  price={total:"",discount:"",net:""};
  shippingOpitons=new Array();
  cartData;
  selectedOption;
  lastSelectedOption;
  count;


  constructor(private _cartService:CartService,
              private _addressService:AddressService,
              private _router:Router,
              private _paymentService:PaymentService,
              private _authService:AuthService,
              private _dataExchangeService:DataExchangeService) { }

  ngOnInit() {

    //If user id not authenticated,transfer control over homepage.

    if(!this._authService.loggedIn() && localStorage.getItem("payment")==null){
      this._router.navigate(['']);
    } else {
      if(localStorage.getItem("payment")!="address"){
        this._router.navigate(['']);
      }
      localStorage.removeItem("payment");
    }

    // Get cart data for calculating amount of payment 

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
            if(this.cartData[i].product_variant_id==this.productData[j].variant_id){
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
                image:this.productData[j].image,
                attributes:this.cartData[i].attributes
              };
              total=total+this.productData[j].price*this.cartData[i].quantity+this.productData[j].discounted_price;
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
    )
    
  }

  /* * open stripe payment interface for payment if user click on payment
     * if token is returned by stripe payment interface, it will confirm the payment and place the order and send confirmation mail to user.
  */

  openCheckout(){
    this.handler = (<any>window).StripeCheckout.configure({
      key: 'pk_test_XfbeMez71536uyZV10cMz4ZI00rFqtzMPs',
      locale: 'auto',
      token: token => {
        let paymentToken={
          stripeToken:token,
          amount:Number(this.price.net),
          shipping_id:this.selectedOption,
          days:this.shippingOpitons.find(item=>item.shipping_id==this.selectedOption).days
        }
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
  
  // If shipping options changed, it will calculate price of order according to shipping option charges.

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

  // If user click to cart tab, it will transfer control to cart page.

  clickBag(){
    this._router.navigate(['cart']);
  }

  // If user want to change the address,  it will transfer control to address page.
  clickAddress(){
    this._router.navigate(['address']);
  }

  // it will close stripe payment interface after completing transaction.

  @HostListener('window:popstate')
    onPopstate() {
      this.handler.close()
    }
}
