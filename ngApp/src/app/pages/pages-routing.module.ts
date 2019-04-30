import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { LayoutComponent } from '../theme/layout/layout.component';
import { ProductsComponent } from './products/products.component';
import { LoginComponent } from './authentication/login/login.component';
import { RegisterComponent } from './authentication/register/register.component';
import { AuthGuard } from '../auth.guard';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { CartDetailComponent } from './cart-detail/cart-detail.component';
import { WishlistComponent } from './wishlist/wishlist.component';
import { AddAddressComponent } from './checkout/add-address/add-address.component';
import { PaymentComponent } from './checkout/payment/payment.component';
import { AddressComponent } from './checkout/address/address.component';
import { OrderDetailComponent } from './checkout/order-detail/order-detail.component';

const routes: Routes = [
  {
    path:'',
    component:LayoutComponent,
    children:[
      {
        path:'',
        component:ProductsComponent
      },
      {
        path:'login',
        component:LoginComponent,
      },
      {
        path:'register',
        component:RegisterComponent
      },
      {
        path:'product/:id',
        component:ProductDetailComponent
      },
      {
        path:'cart',
        component:CartDetailComponent
      },
      {
        path:'wishlist',
        component:WishlistComponent
      },
      {
        path:'add-address',
        component:AddAddressComponent
      },
      {
        path:'payment',
        component:PaymentComponent
      },
      {
        path:'address',
        component:AddressComponent
      },
      {
        path:'orders',
        component:OrderDetailComponent
      }
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class PagesRoutingModule { }
