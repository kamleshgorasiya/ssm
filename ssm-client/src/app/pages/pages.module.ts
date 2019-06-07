import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { PagesRoutingModule } from './pages-routing.module';
import { ProductsComponent } from './product/products/products.component';
import { ThemeModule } from '../theme/theme.module';
import { SidebarComponent } from '../theme/sidebar/sidebar.component';
import { AuthenticationModule } from './authentication/authentication.module';
import { ProductDetailComponent } from './product/product-detail/product-detail.component';
import { CartDetailComponent } from './cart-detail/cart-detail.component';
import { WishlistComponent } from './wishlist/wishlist/wishlist.component';
import { CheckoutModule } from './checkout/checkout.module';
import { ProductModule } from './product/product.module';
import { HttpClientModule } from '@angular/common/http';
import { HomeModule } from './home/home.module';
import { WishlistModule } from './wishlist/wishlist.module';


@NgModule({
  declarations: [SidebarComponent, CartDetailComponent],
  imports: [
    CommonModule,
    PagesRoutingModule,
    ThemeModule,
    AuthenticationModule,
    CheckoutModule,
    ProductModule,
    HttpClientModule,
    ProductModule,
    HomeModule,
    WishlistModule
  ],
  exports:[SidebarComponent,CartDetailComponent]
})
export class PagesModule { }
