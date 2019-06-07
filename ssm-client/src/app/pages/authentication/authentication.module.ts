import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LoginComponent } from './login/login.component';
import { FormsModule } from '@angular/forms';
import { RegisterComponent } from './register/register.component';
import { RouterModule } from '@angular/router';
import { ResetPasswordComponent } from './reset-password/reset-password.component';

@NgModule({
  declarations: [ LoginComponent, RegisterComponent, ResetPasswordComponent],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class AuthenticationModule { }
