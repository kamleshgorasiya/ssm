import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { LayoutComponent } from '../theme/layout/layout.component';
import { ProductsComponent } from './product/products/products.component';
import { LoginComponent } from './authentication/login/login.component';
import { RegisterComponent } from './authentication/register/register.component';
import { ProductDetailComponent } from './product/product-detail/product-detail.component';
import { CartDetailComponent } from './cart-detail/cart-detail.component';
import { WishlistComponent } from './wishlist/wishlist/wishlist.component';
import { AddAddressComponent } from './checkout/add-address/add-address.component';
import { PaymentComponent } from './checkout/payment/payment.component';
import { AddressComponent } from './checkout/address/address.component';
import { OrderDetailComponent } from './checkout/order-detail/order-detail.component';
import { SearchProductComponent } from './product/search-product/search-product.component';
import { CategoryProductComponent } from './product/category-product/category-product.component';
import { HomepageComponent } from './home/homepage/homepage.component';
import { ResetPasswordComponent } from './authentication/reset-password/reset-password.component';

const routes: Routes = [
  {
    path:'',
    component:LayoutComponent,
    children:[
      {
        path:'',
        component:HomepageComponent
      },
      {
        path:'search/:search',
        component:SearchProductComponent
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
      },
      {
        path:'category/:id/:name',
        component:CategoryProductComponent
      },
      {
        path:'products',
        component:ProductsComponent
      },
      {
        path:'reset-password',
        component:ResetPasswordComponent
      }
     
    ]
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class PagesRoutingModule { }
