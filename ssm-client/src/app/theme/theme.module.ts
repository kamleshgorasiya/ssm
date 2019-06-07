import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ThemeRoutingModule } from './theme-routing.module';
import { HeaderComponent } from './header/header.component';
import { LayoutComponent } from './layout/layout.component';
import { RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { PagesModule } from '../pages/pages.module';
import { FooterComponent } from './footer/footer.component';

@NgModule({
  declarations: [HeaderComponent, LayoutComponent, FooterComponent],
  imports: [
    CommonModule,
    ThemeRoutingModule,
    RouterModule,
    FormsModule
  ]
})
export class ThemeModule { }
