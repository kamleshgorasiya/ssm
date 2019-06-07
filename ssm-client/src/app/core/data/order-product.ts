/**
 *  Model class for displaying Order Products
 * 
 *  Properties :-
 * 
 *  @orderId:number;
 *  @product_id:number;
 *  @name:string;
 *  @description:string;
 *  @attributes:{};
 *  @price:number;
 *  @discounted_price:number;
 *  @placedDate:Date;
 *  @shippingDate:Date;
 *  @deliveryDate:Date;
 *  @image:string;
 *  @quantity:number;
 *  @cancel:number;
 *  @status_id:number;
 */

export class OrderProduct {
    orderId:number;
    product_id:number;
    name:string;
    description:string;
    attributes:{};
    price:number;
    discounted_price:number;
    placedDate:Date;
    shippingDate:Date;
    deliveryDate:Date;
    image:string;
    quantity:number;
    cancel:number;
    status_id:number;
}
