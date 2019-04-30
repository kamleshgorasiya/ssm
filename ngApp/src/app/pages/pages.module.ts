import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { PagesRoutingModule } from './pages-routing.module';
import { ProductsComponent } from './products/products.component';
import { ThemeModule } from '../theme/theme.module';
import { SidebarComponent } from '../theme/sidebar/sidebar.component';
import { AuthenticationModule } from './authentication/authentication.module';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { CartDetailComponent } from './cart-detail/cart-detail.component';
import { WishlistComponent } from './wishlist/wishlist.component';
import { CheckoutModule } from './checkout/checkout.module';


@NgModule({
  declarations: [ProductsComponent,SidebarComponent, ProductDetailComponent, CartDetailComponent, WishlistComponent],
  imports: [
    CommonModule,
    PagesRoutingModule,
    ThemeModule,
    AuthenticationModule,
    CheckoutModule
  ]
})
export class PagesModule { }
