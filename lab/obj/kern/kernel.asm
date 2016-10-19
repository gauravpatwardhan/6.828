
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 33 00 00 00       	call   f0100071 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 08             	sub    $0x8,%esp
f0100046:	8b 45 08             	mov    0x8(%ebp),%eax
//	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
f0100049:	85 c0                	test   %eax,%eax
f010004b:	7e 11                	jle    f010005e <test_backtrace+0x1e>
		test_backtrace(x-1);
f010004d:	83 ec 0c             	sub    $0xc,%esp
f0100050:	83 e8 01             	sub    $0x1,%eax
f0100053:	50                   	push   %eax
f0100054:	e8 e7 ff ff ff       	call   f0100040 <test_backtrace>
f0100059:	83 c4 10             	add    $0x10,%esp
f010005c:	eb 11                	jmp    f010006f <test_backtrace+0x2f>
	else
		mon_backtrace(0, 0, 0);
f010005e:	83 ec 04             	sub    $0x4,%esp
f0100061:	6a 00                	push   $0x0
f0100063:	6a 00                	push   $0x0
f0100065:	6a 00                	push   $0x0
f0100067:	e8 e8 06 00 00       	call   f0100754 <mon_backtrace>
f010006c:	83 c4 10             	add    $0x10,%esp
//	cprintf("leaving test_backtrace %d\n", x);
}
f010006f:	c9                   	leave  
f0100070:	c3                   	ret    

f0100071 <i386_init>:

void
i386_init(void)
{
f0100071:	55                   	push   %ebp
f0100072:	89 e5                	mov    %esp,%ebp
f0100074:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100077:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010007c:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100081:	50                   	push   %eax
f0100082:	6a 00                	push   $0x0
f0100084:	68 00 23 11 f0       	push   $0xf0112300
f0100089:	e8 ba 13 00 00       	call   f0101448 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010008e:	e8 8f 04 00 00       	call   f0100522 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100093:	83 c4 08             	add    $0x8,%esp
f0100096:	68 ac 1a 00 00       	push   $0x1aac
f010009b:	68 e0 18 10 f0       	push   $0xf01018e0
f01000a0:	e8 ea 08 00 00       	call   f010098f <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000a5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ac:	e8 8f ff ff ff       	call   f0100040 <test_backtrace>
f01000b1:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000b4:	83 ec 0c             	sub    $0xc,%esp
f01000b7:	6a 00                	push   $0x0
f01000b9:	e8 64 07 00 00       	call   f0100822 <monitor>
f01000be:	83 c4 10             	add    $0x10,%esp
f01000c1:	eb f1                	jmp    f01000b4 <i386_init+0x43>

f01000c3 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000c3:	55                   	push   %ebp
f01000c4:	89 e5                	mov    %esp,%ebp
f01000c6:	56                   	push   %esi
f01000c7:	53                   	push   %ebx
f01000c8:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000cb:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000d2:	75 37                	jne    f010010b <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000d4:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000da:	fa                   	cli    
f01000db:	fc                   	cld    

	va_start(ap, fmt);
f01000dc:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000df:	83 ec 04             	sub    $0x4,%esp
f01000e2:	ff 75 0c             	pushl  0xc(%ebp)
f01000e5:	ff 75 08             	pushl  0x8(%ebp)
f01000e8:	68 fb 18 10 f0       	push   $0xf01018fb
f01000ed:	e8 9d 08 00 00       	call   f010098f <cprintf>
	vcprintf(fmt, ap);
f01000f2:	83 c4 08             	add    $0x8,%esp
f01000f5:	53                   	push   %ebx
f01000f6:	56                   	push   %esi
f01000f7:	e8 6d 08 00 00       	call   f0100969 <vcprintf>
	cprintf("\n");
f01000fc:	c7 04 24 37 19 10 f0 	movl   $0xf0101937,(%esp)
f0100103:	e8 87 08 00 00       	call   f010098f <cprintf>
	va_end(ap);
f0100108:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010010b:	83 ec 0c             	sub    $0xc,%esp
f010010e:	6a 00                	push   $0x0
f0100110:	e8 0d 07 00 00       	call   f0100822 <monitor>
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	eb f1                	jmp    f010010b <_panic+0x48>

f010011a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011a:	55                   	push   %ebp
f010011b:	89 e5                	mov    %esp,%ebp
f010011d:	53                   	push   %ebx
f010011e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100121:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100124:	ff 75 0c             	pushl  0xc(%ebp)
f0100127:	ff 75 08             	pushl  0x8(%ebp)
f010012a:	68 13 19 10 f0       	push   $0xf0101913
f010012f:	e8 5b 08 00 00       	call   f010098f <cprintf>
	vcprintf(fmt, ap);
f0100134:	83 c4 08             	add    $0x8,%esp
f0100137:	53                   	push   %ebx
f0100138:	ff 75 10             	pushl  0x10(%ebp)
f010013b:	e8 29 08 00 00       	call   f0100969 <vcprintf>
	cprintf("\n");
f0100140:	c7 04 24 37 19 10 f0 	movl   $0xf0101937,(%esp)
f0100147:	e8 43 08 00 00       	call   f010098f <cprintf>
	va_end(ap);
}
f010014c:	83 c4 10             	add    $0x10,%esp
f010014f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100152:	c9                   	leave  
f0100153:	c3                   	ret    

f0100154 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100154:	55                   	push   %ebp
f0100155:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100157:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015d:	a8 01                	test   $0x1,%al
f010015f:	74 0b                	je     f010016c <serial_proc_data+0x18>
f0100161:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100166:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100167:	0f b6 c0             	movzbl %al,%eax
f010016a:	eb 05                	jmp    f0100171 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010016c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100171:	5d                   	pop    %ebp
f0100172:	c3                   	ret    

f0100173 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100173:	55                   	push   %ebp
f0100174:	89 e5                	mov    %esp,%ebp
f0100176:	53                   	push   %ebx
f0100177:	83 ec 04             	sub    $0x4,%esp
f010017a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010017c:	eb 2b                	jmp    f01001a9 <cons_intr+0x36>
		if (c == 0)
f010017e:	85 c0                	test   %eax,%eax
f0100180:	74 27                	je     f01001a9 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100182:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f0100188:	8d 51 01             	lea    0x1(%ecx),%edx
f010018b:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f0100191:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100197:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010019d:	75 0a                	jne    f01001a9 <cons_intr+0x36>
			cons.wpos = 0;
f010019f:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001a6:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a9:	ff d3                	call   *%ebx
f01001ab:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ae:	75 ce                	jne    f010017e <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001b0:	83 c4 04             	add    $0x4,%esp
f01001b3:	5b                   	pop    %ebx
f01001b4:	5d                   	pop    %ebp
f01001b5:	c3                   	ret    

f01001b6 <kbd_proc_data>:
f01001b6:	ba 64 00 00 00       	mov    $0x64,%edx
f01001bb:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	0f 84 f0 00 00 00    	je     f01002b4 <kbd_proc_data+0xfe>
f01001c4:	ba 60 00 00 00       	mov    $0x60,%edx
f01001c9:	ec                   	in     (%dx),%al
f01001ca:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001cc:	3c e0                	cmp    $0xe0,%al
f01001ce:	75 0d                	jne    f01001dd <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001d0:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001d7:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001dc:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001dd:	55                   	push   %ebp
f01001de:	89 e5                	mov    %esp,%ebp
f01001e0:	53                   	push   %ebx
f01001e1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001e4:	84 c0                	test   %al,%al
f01001e6:	79 36                	jns    f010021e <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001e8:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01001ee:	89 cb                	mov    %ecx,%ebx
f01001f0:	83 e3 40             	and    $0x40,%ebx
f01001f3:	83 e0 7f             	and    $0x7f,%eax
f01001f6:	85 db                	test   %ebx,%ebx
f01001f8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001fb:	0f b6 d2             	movzbl %dl,%edx
f01001fe:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f0100205:	83 c8 40             	or     $0x40,%eax
f0100208:	0f b6 c0             	movzbl %al,%eax
f010020b:	f7 d0                	not    %eax
f010020d:	21 c8                	and    %ecx,%eax
f010020f:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100214:	b8 00 00 00 00       	mov    $0x0,%eax
f0100219:	e9 9e 00 00 00       	jmp    f01002bc <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010021e:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100224:	f6 c1 40             	test   $0x40,%cl
f0100227:	74 0e                	je     f0100237 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100229:	83 c8 80             	or     $0xffffff80,%eax
f010022c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010022e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100231:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100237:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010023a:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f0100241:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100247:	0f b6 8a 80 19 10 f0 	movzbl -0xfefe680(%edx),%ecx
f010024e:	31 c8                	xor    %ecx,%eax
f0100250:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100255:	89 c1                	mov    %eax,%ecx
f0100257:	83 e1 03             	and    $0x3,%ecx
f010025a:	8b 0c 8d 60 19 10 f0 	mov    -0xfefe6a0(,%ecx,4),%ecx
f0100261:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100265:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100268:	a8 08                	test   $0x8,%al
f010026a:	74 1b                	je     f0100287 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010026c:	89 da                	mov    %ebx,%edx
f010026e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100271:	83 f9 19             	cmp    $0x19,%ecx
f0100274:	77 05                	ja     f010027b <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100276:	83 eb 20             	sub    $0x20,%ebx
f0100279:	eb 0c                	jmp    f0100287 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010027b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010027e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100281:	83 fa 19             	cmp    $0x19,%edx
f0100284:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100287:	f7 d0                	not    %eax
f0100289:	a8 06                	test   $0x6,%al
f010028b:	75 2d                	jne    f01002ba <kbd_proc_data+0x104>
f010028d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100293:	75 25                	jne    f01002ba <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100295:	83 ec 0c             	sub    $0xc,%esp
f0100298:	68 2d 19 10 f0       	push   $0xf010192d
f010029d:	e8 ed 06 00 00       	call   f010098f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01002ac:	ee                   	out    %al,(%dx)
f01002ad:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b0:	89 d8                	mov    %ebx,%eax
f01002b2:	eb 08                	jmp    f01002bc <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002b9:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002ba:	89 d8                	mov    %ebx,%eax
}
f01002bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002bf:	c9                   	leave  
f01002c0:	c3                   	ret    

f01002c1 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c1:	55                   	push   %ebp
f01002c2:	89 e5                	mov    %esp,%ebp
f01002c4:	57                   	push   %edi
f01002c5:	56                   	push   %esi
f01002c6:	53                   	push   %ebx
f01002c7:	83 ec 1c             	sub    $0x1c,%esp
f01002ca:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002cc:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d1:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002d6:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002db:	eb 09                	jmp    f01002e6 <cons_putc+0x25>
f01002dd:	89 ca                	mov    %ecx,%edx
f01002df:	ec                   	in     (%dx),%al
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	ec                   	in     (%dx),%al
f01002e2:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002e3:	83 c3 01             	add    $0x1,%ebx
f01002e6:	89 f2                	mov    %esi,%edx
f01002e8:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002e9:	a8 20                	test   $0x20,%al
f01002eb:	75 08                	jne    f01002f5 <cons_putc+0x34>
f01002ed:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f3:	7e e8                	jle    f01002dd <cons_putc+0x1c>
f01002f5:	89 f8                	mov    %edi,%eax
f01002f7:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002fa:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ff:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100300:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100305:	be 79 03 00 00       	mov    $0x379,%esi
f010030a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030f:	eb 09                	jmp    f010031a <cons_putc+0x59>
f0100311:	89 ca                	mov    %ecx,%edx
f0100313:	ec                   	in     (%dx),%al
f0100314:	ec                   	in     (%dx),%al
f0100315:	ec                   	in     (%dx),%al
f0100316:	ec                   	in     (%dx),%al
f0100317:	83 c3 01             	add    $0x1,%ebx
f010031a:	89 f2                	mov    %esi,%edx
f010031c:	ec                   	in     (%dx),%al
f010031d:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100323:	7f 04                	jg     f0100329 <cons_putc+0x68>
f0100325:	84 c0                	test   %al,%al
f0100327:	79 e8                	jns    f0100311 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100329:	ba 78 03 00 00       	mov    $0x378,%edx
f010032e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100332:	ee                   	out    %al,(%dx)
f0100333:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100338:	b8 0d 00 00 00       	mov    $0xd,%eax
f010033d:	ee                   	out    %al,(%dx)
f010033e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100343:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100344:	89 fa                	mov    %edi,%edx
f0100346:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010034c:	89 f8                	mov    %edi,%eax
f010034e:	80 cc 07             	or     $0x7,%ah
f0100351:	85 d2                	test   %edx,%edx
f0100353:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100356:	89 f8                	mov    %edi,%eax
f0100358:	0f b6 c0             	movzbl %al,%eax
f010035b:	83 f8 09             	cmp    $0x9,%eax
f010035e:	74 74                	je     f01003d4 <cons_putc+0x113>
f0100360:	83 f8 09             	cmp    $0x9,%eax
f0100363:	7f 0a                	jg     f010036f <cons_putc+0xae>
f0100365:	83 f8 08             	cmp    $0x8,%eax
f0100368:	74 14                	je     f010037e <cons_putc+0xbd>
f010036a:	e9 99 00 00 00       	jmp    f0100408 <cons_putc+0x147>
f010036f:	83 f8 0a             	cmp    $0xa,%eax
f0100372:	74 3a                	je     f01003ae <cons_putc+0xed>
f0100374:	83 f8 0d             	cmp    $0xd,%eax
f0100377:	74 3d                	je     f01003b6 <cons_putc+0xf5>
f0100379:	e9 8a 00 00 00       	jmp    f0100408 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010037e:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100385:	66 85 c0             	test   %ax,%ax
f0100388:	0f 84 e6 00 00 00    	je     f0100474 <cons_putc+0x1b3>
			crt_pos--;
f010038e:	83 e8 01             	sub    $0x1,%eax
f0100391:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100397:	0f b7 c0             	movzwl %ax,%eax
f010039a:	66 81 e7 00 ff       	and    $0xff00,%di
f010039f:	83 cf 20             	or     $0x20,%edi
f01003a2:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003a8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ac:	eb 78                	jmp    f0100426 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ae:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003b5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b6:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003bd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c3:	c1 e8 16             	shr    $0x16,%eax
f01003c6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c9:	c1 e0 04             	shl    $0x4,%eax
f01003cc:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003d2:	eb 52                	jmp    f0100426 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d9:	e8 e3 fe ff ff       	call   f01002c1 <cons_putc>
		cons_putc(' ');
f01003de:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e3:	e8 d9 fe ff ff       	call   f01002c1 <cons_putc>
		cons_putc(' ');
f01003e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ed:	e8 cf fe ff ff       	call   f01002c1 <cons_putc>
		cons_putc(' ');
f01003f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f7:	e8 c5 fe ff ff       	call   f01002c1 <cons_putc>
		cons_putc(' ');
f01003fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100401:	e8 bb fe ff ff       	call   f01002c1 <cons_putc>
f0100406:	eb 1e                	jmp    f0100426 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100408:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010040f:	8d 50 01             	lea    0x1(%eax),%edx
f0100412:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100419:	0f b7 c0             	movzwl %ax,%eax
f010041c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100422:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100426:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010042d:	cf 07 
f010042f:	76 43                	jbe    f0100474 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100431:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100436:	83 ec 04             	sub    $0x4,%esp
f0100439:	68 00 0f 00 00       	push   $0xf00
f010043e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100444:	52                   	push   %edx
f0100445:	50                   	push   %eax
f0100446:	e8 4a 10 00 00       	call   f0101495 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044b:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100451:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100457:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010045d:	83 c4 10             	add    $0x10,%esp
f0100460:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100465:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100468:	39 d0                	cmp    %edx,%eax
f010046a:	75 f4                	jne    f0100460 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010046c:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100473:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100474:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f010047a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047f:	89 ca                	mov    %ecx,%edx
f0100481:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100482:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f0100489:	8d 71 01             	lea    0x1(%ecx),%esi
f010048c:	89 d8                	mov    %ebx,%eax
f010048e:	66 c1 e8 08          	shr    $0x8,%ax
f0100492:	89 f2                	mov    %esi,%edx
f0100494:	ee                   	out    %al,(%dx)
f0100495:	b8 0f 00 00 00       	mov    $0xf,%eax
f010049a:	89 ca                	mov    %ecx,%edx
f010049c:	ee                   	out    %al,(%dx)
f010049d:	89 d8                	mov    %ebx,%eax
f010049f:	89 f2                	mov    %esi,%edx
f01004a1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004a5:	5b                   	pop    %ebx
f01004a6:	5e                   	pop    %esi
f01004a7:	5f                   	pop    %edi
f01004a8:	5d                   	pop    %ebp
f01004a9:	c3                   	ret    

f01004aa <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004aa:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004b1:	74 11                	je     f01004c4 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b3:	55                   	push   %ebp
f01004b4:	89 e5                	mov    %esp,%ebp
f01004b6:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b9:	b8 54 01 10 f0       	mov    $0xf0100154,%eax
f01004be:	e8 b0 fc ff ff       	call   f0100173 <cons_intr>
}
f01004c3:	c9                   	leave  
f01004c4:	f3 c3                	repz ret 

f01004c6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c6:	55                   	push   %ebp
f01004c7:	89 e5                	mov    %esp,%ebp
f01004c9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004cc:	b8 b6 01 10 f0       	mov    $0xf01001b6,%eax
f01004d1:	e8 9d fc ff ff       	call   f0100173 <cons_intr>
}
f01004d6:	c9                   	leave  
f01004d7:	c3                   	ret    

f01004d8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d8:	55                   	push   %ebp
f01004d9:	89 e5                	mov    %esp,%ebp
f01004db:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004de:	e8 c7 ff ff ff       	call   f01004aa <serial_intr>
	kbd_intr();
f01004e3:	e8 de ff ff ff       	call   f01004c6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e8:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f01004ed:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f01004f3:	74 26                	je     f010051b <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004f5:	8d 50 01             	lea    0x1(%eax),%edx
f01004f8:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f01004fe:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100505:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100507:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050d:	75 11                	jne    f0100520 <cons_getc+0x48>
			cons.rpos = 0;
f010050f:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100516:	00 00 00 
f0100519:	eb 05                	jmp    f0100520 <cons_getc+0x48>
		return c;
	}
	return 0;
f010051b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100520:	c9                   	leave  
f0100521:	c3                   	ret    

f0100522 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100522:	55                   	push   %ebp
f0100523:	89 e5                	mov    %esp,%ebp
f0100525:	57                   	push   %edi
f0100526:	56                   	push   %esi
f0100527:	53                   	push   %ebx
f0100528:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010052b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100532:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100539:	5a a5 
	if (*cp != 0xA55A) {
f010053b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100542:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100546:	74 11                	je     f0100559 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100548:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010054f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100552:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100557:	eb 16                	jmp    f010056f <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100559:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100560:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100567:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010056a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056f:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f0100575:	b8 0e 00 00 00       	mov    $0xe,%eax
f010057a:	89 fa                	mov    %edi,%edx
f010057c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010057d:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100580:	89 da                	mov    %ebx,%edx
f0100582:	ec                   	in     (%dx),%al
f0100583:	0f b6 c8             	movzbl %al,%ecx
f0100586:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100589:	b8 0f 00 00 00       	mov    $0xf,%eax
f010058e:	89 fa                	mov    %edi,%edx
f0100590:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100591:	89 da                	mov    %ebx,%edx
f0100593:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100594:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f010059a:	0f b6 c0             	movzbl %al,%eax
f010059d:	09 c8                	or     %ecx,%eax
f010059f:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01005af:	89 f2                	mov    %esi,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005c2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005c7:	89 da                	mov    %ebx,%edx
f01005c9:	ee                   	out    %al,(%dx)
f01005ca:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005da:	b8 03 00 00 00       	mov    $0x3,%eax
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ea:	ee                   	out    %al,(%dx)
f01005eb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01005f5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005fb:	ec                   	in     (%dx),%al
f01005fc:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005fe:	3c ff                	cmp    $0xff,%al
f0100600:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100607:	89 f2                	mov    %esi,%edx
f0100609:	ec                   	in     (%dx),%al
f010060a:	89 da                	mov    %ebx,%edx
f010060c:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010060d:	80 f9 ff             	cmp    $0xff,%cl
f0100610:	75 10                	jne    f0100622 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100612:	83 ec 0c             	sub    $0xc,%esp
f0100615:	68 39 19 10 f0       	push   $0xf0101939
f010061a:	e8 70 03 00 00       	call   f010098f <cprintf>
f010061f:	83 c4 10             	add    $0x10,%esp
}
f0100622:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100625:	5b                   	pop    %ebx
f0100626:	5e                   	pop    %esi
f0100627:	5f                   	pop    %edi
f0100628:	5d                   	pop    %ebp
f0100629:	c3                   	ret    

f010062a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010062a:	55                   	push   %ebp
f010062b:	89 e5                	mov    %esp,%ebp
f010062d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100630:	8b 45 08             	mov    0x8(%ebp),%eax
f0100633:	e8 89 fc ff ff       	call   f01002c1 <cons_putc>
}
f0100638:	c9                   	leave  
f0100639:	c3                   	ret    

f010063a <getchar>:

int
getchar(void)
{
f010063a:	55                   	push   %ebp
f010063b:	89 e5                	mov    %esp,%ebp
f010063d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100640:	e8 93 fe ff ff       	call   f01004d8 <cons_getc>
f0100645:	85 c0                	test   %eax,%eax
f0100647:	74 f7                	je     f0100640 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100649:	c9                   	leave  
f010064a:	c3                   	ret    

f010064b <iscons>:

int
iscons(int fdnum)
{
f010064b:	55                   	push   %ebp
f010064c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010064e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100653:	5d                   	pop    %ebp
f0100654:	c3                   	ret    

f0100655 <mon_help>:



int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065b:	68 80 1b 10 f0       	push   $0xf0101b80
f0100660:	68 9e 1b 10 f0       	push   $0xf0101b9e
f0100665:	68 a3 1b 10 f0       	push   $0xf0101ba3
f010066a:	e8 20 03 00 00       	call   f010098f <cprintf>
f010066f:	83 c4 0c             	add    $0xc,%esp
f0100672:	68 58 1c 10 f0       	push   $0xf0101c58
f0100677:	68 ac 1b 10 f0       	push   $0xf0101bac
f010067c:	68 a3 1b 10 f0       	push   $0xf0101ba3
f0100681:	e8 09 03 00 00       	call   f010098f <cprintf>
f0100686:	83 c4 0c             	add    $0xc,%esp
f0100689:	68 b5 1b 10 f0       	push   $0xf0101bb5
f010068e:	68 cc 1b 10 f0       	push   $0xf0101bcc
f0100693:	68 a3 1b 10 f0       	push   $0xf0101ba3
f0100698:	e8 f2 02 00 00       	call   f010098f <cprintf>
	return 0;
}
f010069d:	b8 00 00 00 00       	mov    $0x0,%eax
f01006a2:	c9                   	leave  
f01006a3:	c3                   	ret    

f01006a4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006a4:	55                   	push   %ebp
f01006a5:	89 e5                	mov    %esp,%ebp
f01006a7:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006aa:	68 d6 1b 10 f0       	push   $0xf0101bd6
f01006af:	e8 db 02 00 00       	call   f010098f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006b4:	83 c4 08             	add    $0x8,%esp
f01006b7:	68 0c 00 10 00       	push   $0x10000c
f01006bc:	68 80 1c 10 f0       	push   $0xf0101c80
f01006c1:	e8 c9 02 00 00       	call   f010098f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006c6:	83 c4 0c             	add    $0xc,%esp
f01006c9:	68 0c 00 10 00       	push   $0x10000c
f01006ce:	68 0c 00 10 f0       	push   $0xf010000c
f01006d3:	68 a8 1c 10 f0       	push   $0xf0101ca8
f01006d8:	e8 b2 02 00 00       	call   f010098f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006dd:	83 c4 0c             	add    $0xc,%esp
f01006e0:	68 d1 18 10 00       	push   $0x1018d1
f01006e5:	68 d1 18 10 f0       	push   $0xf01018d1
f01006ea:	68 cc 1c 10 f0       	push   $0xf0101ccc
f01006ef:	e8 9b 02 00 00       	call   f010098f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006f4:	83 c4 0c             	add    $0xc,%esp
f01006f7:	68 00 23 11 00       	push   $0x112300
f01006fc:	68 00 23 11 f0       	push   $0xf0112300
f0100701:	68 f0 1c 10 f0       	push   $0xf0101cf0
f0100706:	e8 84 02 00 00       	call   f010098f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010070b:	83 c4 0c             	add    $0xc,%esp
f010070e:	68 44 29 11 00       	push   $0x112944
f0100713:	68 44 29 11 f0       	push   $0xf0112944
f0100718:	68 14 1d 10 f0       	push   $0xf0101d14
f010071d:	e8 6d 02 00 00       	call   f010098f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100722:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100727:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010072c:	83 c4 08             	add    $0x8,%esp
f010072f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100734:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010073a:	85 c0                	test   %eax,%eax
f010073c:	0f 48 c2             	cmovs  %edx,%eax
f010073f:	c1 f8 0a             	sar    $0xa,%eax
f0100742:	50                   	push   %eax
f0100743:	68 38 1d 10 f0       	push   $0xf0101d38
f0100748:	e8 42 02 00 00       	call   f010098f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010074d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
f0100757:	57                   	push   %edi
f0100758:	56                   	push   %esi
f0100759:	53                   	push   %ebx
f010075a:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	
	//basic stack backtrace code
	cprintf("Stack backtrace:\n");
f010075d:	68 ef 1b 10 f0       	push   $0xf0101bef
f0100762:	e8 28 02 00 00       	call   f010098f <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100767:	89 eb                	mov    %ebp,%ebx
	uintptr_t ebp_current_local = read_ebp();
	uintptr_t eip_current_local = 0;
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};
f0100769:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100770:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100777:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010077e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100785:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
f010078c:	83 c4 0c             	add    $0xc,%esp
f010078f:	6a 18                	push   $0x18
f0100791:	6a 00                	push   $0x0
f0100793:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100796:	50                   	push   %eax
f0100797:	e8 ac 0c 00 00       	call   f0101448 <memset>
	while (ebp_current_local != 0){
f010079c:	83 c4 10             	add    $0x10,%esp
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f010079f:	8d 7d bc             	lea    -0x44(%ebp),%edi
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f01007a2:	eb 6d                	jmp    f0100811 <mon_backtrace+0xbd>
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
f01007a4:	8b 73 04             	mov    0x4(%ebx),%esi
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007a7:	b8 00 00 00 00       	mov    $0x0,%eax
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
f01007ac:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f01007b0:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
		eip_current_local = *((uintptr_t *)(ebp_current_local) + 1);
		// fill the array with args
		int i = 0;
		for ( i = 0; i < MAX_ARGS_PASSED ; i++ ){
f01007b4:	83 c0 01             	add    $0x1,%eax
f01007b7:	83 f8 05             	cmp    $0x5,%eax
f01007ba:	75 f0                	jne    f01007ac <mon_backtrace+0x58>
			args_arr[i] = *((uint32_t *)(ebp_current_local) + i+2) ;
		}
		cprintf(" ebp %x eip %x args %8.0x %8.0x %8.0x %8.0x %8.0x\n", ebp_current_local,
f01007bc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007bf:	ff 75 e0             	pushl  -0x20(%ebp)
f01007c2:	ff 75 dc             	pushl  -0x24(%ebp)
f01007c5:	ff 75 d8             	pushl  -0x28(%ebp)
f01007c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007cb:	56                   	push   %esi
f01007cc:	53                   	push   %ebx
f01007cd:	68 64 1d 10 f0       	push   $0xf0101d64
f01007d2:	e8 b8 01 00 00       	call   f010098f <cprintf>
               eip_current_local, args_arr[0], args_arr[1], args_arr[2], args_arr[3], 
               args_arr[4] );
		if (0 == debuginfo_eip(eip_current_local, &eipinfo)){
f01007d7:	83 c4 18             	add    $0x18,%esp
f01007da:	57                   	push   %edi
f01007db:	56                   	push   %esi
f01007dc:	e8 b8 02 00 00       	call   f0100a99 <debuginfo_eip>
f01007e1:	83 c4 10             	add    $0x10,%esp
f01007e4:	85 c0                	test   %eax,%eax
f01007e6:	75 20                	jne    f0100808 <mon_backtrace+0xb4>
//				cprintf("        %s:%d:\n", eipinfo.eip_file, eipinfo.eip_line);	
				cprintf("        %s:%d: %.*s+%d\n", eipinfo.eip_file, eipinfo.eip_line, eipinfo.eip_fn_namelen, eipinfo.eip_fn_name, eip_current_local-eipinfo.eip_fn_addr);
f01007e8:	83 ec 08             	sub    $0x8,%esp
f01007eb:	2b 75 cc             	sub    -0x34(%ebp),%esi
f01007ee:	56                   	push   %esi
f01007ef:	ff 75 c4             	pushl  -0x3c(%ebp)
f01007f2:	ff 75 c8             	pushl  -0x38(%ebp)
f01007f5:	ff 75 c0             	pushl  -0x40(%ebp)
f01007f8:	ff 75 bc             	pushl  -0x44(%ebp)
f01007fb:	68 01 1c 10 f0       	push   $0xf0101c01
f0100800:	e8 8a 01 00 00       	call   f010098f <cprintf>
f0100805:	83 c4 20             	add    $0x20,%esp

		}
		// point the ebp to the next ebp using the current ebp value pushed on stack	
		ebp_current_local = *(uintptr_t *)(ebp_current_local);
f0100808:	8b 1b                	mov    (%ebx),%ebx
f010080a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	uint32_t args_arr[MAX_ARGS_PASSED]= {0};

	// eip debug information
	struct Eipdebuginfo eipinfo ;
	memset (&eipinfo, 0, sizeof(struct Eipdebuginfo));
	while (ebp_current_local != 0){
f0100811:	85 db                	test   %ebx,%ebx
f0100813:	75 8f                	jne    f01007a4 <mon_backtrace+0x50>
		for ( i = 0; i < MAX_ARGS_PASSED; i++){
			args_arr[0] = 0;
		}
	}
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100822:	55                   	push   %ebp
f0100823:	89 e5                	mov    %esp,%ebp
f0100825:	57                   	push   %edi
f0100826:	56                   	push   %esi
f0100827:	53                   	push   %ebx
f0100828:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010082b:	68 98 1d 10 f0       	push   $0xf0101d98
f0100830:	e8 5a 01 00 00       	call   f010098f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100835:	c7 04 24 bc 1d 10 f0 	movl   $0xf0101dbc,(%esp)
f010083c:	e8 4e 01 00 00       	call   f010098f <cprintf>
f0100841:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100844:	83 ec 0c             	sub    $0xc,%esp
f0100847:	68 19 1c 10 f0       	push   $0xf0101c19
f010084c:	e8 a0 09 00 00       	call   f01011f1 <readline>
f0100851:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100853:	83 c4 10             	add    $0x10,%esp
f0100856:	85 c0                	test   %eax,%eax
f0100858:	74 ea                	je     f0100844 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010085a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100861:	be 00 00 00 00       	mov    $0x0,%esi
f0100866:	eb 0a                	jmp    f0100872 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100868:	c6 03 00             	movb   $0x0,(%ebx)
f010086b:	89 f7                	mov    %esi,%edi
f010086d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100870:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100872:	0f b6 03             	movzbl (%ebx),%eax
f0100875:	84 c0                	test   %al,%al
f0100877:	74 63                	je     f01008dc <monitor+0xba>
f0100879:	83 ec 08             	sub    $0x8,%esp
f010087c:	0f be c0             	movsbl %al,%eax
f010087f:	50                   	push   %eax
f0100880:	68 1d 1c 10 f0       	push   $0xf0101c1d
f0100885:	e8 81 0b 00 00       	call   f010140b <strchr>
f010088a:	83 c4 10             	add    $0x10,%esp
f010088d:	85 c0                	test   %eax,%eax
f010088f:	75 d7                	jne    f0100868 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100891:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100894:	74 46                	je     f01008dc <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100896:	83 fe 0f             	cmp    $0xf,%esi
f0100899:	75 14                	jne    f01008af <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010089b:	83 ec 08             	sub    $0x8,%esp
f010089e:	6a 10                	push   $0x10
f01008a0:	68 22 1c 10 f0       	push   $0xf0101c22
f01008a5:	e8 e5 00 00 00       	call   f010098f <cprintf>
f01008aa:	83 c4 10             	add    $0x10,%esp
f01008ad:	eb 95                	jmp    f0100844 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008af:	8d 7e 01             	lea    0x1(%esi),%edi
f01008b2:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008b6:	eb 03                	jmp    f01008bb <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008b8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bb:	0f b6 03             	movzbl (%ebx),%eax
f01008be:	84 c0                	test   %al,%al
f01008c0:	74 ae                	je     f0100870 <monitor+0x4e>
f01008c2:	83 ec 08             	sub    $0x8,%esp
f01008c5:	0f be c0             	movsbl %al,%eax
f01008c8:	50                   	push   %eax
f01008c9:	68 1d 1c 10 f0       	push   $0xf0101c1d
f01008ce:	e8 38 0b 00 00       	call   f010140b <strchr>
f01008d3:	83 c4 10             	add    $0x10,%esp
f01008d6:	85 c0                	test   %eax,%eax
f01008d8:	74 de                	je     f01008b8 <monitor+0x96>
f01008da:	eb 94                	jmp    f0100870 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008dc:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e3:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e4:	85 f6                	test   %esi,%esi
f01008e6:	0f 84 58 ff ff ff    	je     f0100844 <monitor+0x22>
f01008ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f1:	83 ec 08             	sub    $0x8,%esp
f01008f4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008f7:	ff 34 85 00 1e 10 f0 	pushl  -0xfefe200(,%eax,4)
f01008fe:	ff 75 a8             	pushl  -0x58(%ebp)
f0100901:	e8 a7 0a 00 00       	call   f01013ad <strcmp>
f0100906:	83 c4 10             	add    $0x10,%esp
f0100909:	85 c0                	test   %eax,%eax
f010090b:	75 21                	jne    f010092e <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010090d:	83 ec 04             	sub    $0x4,%esp
f0100910:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100913:	ff 75 08             	pushl  0x8(%ebp)
f0100916:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100919:	52                   	push   %edx
f010091a:	56                   	push   %esi
f010091b:	ff 14 85 08 1e 10 f0 	call   *-0xfefe1f8(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100922:	83 c4 10             	add    $0x10,%esp
f0100925:	85 c0                	test   %eax,%eax
f0100927:	78 25                	js     f010094e <monitor+0x12c>
f0100929:	e9 16 ff ff ff       	jmp    f0100844 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010092e:	83 c3 01             	add    $0x1,%ebx
f0100931:	83 fb 03             	cmp    $0x3,%ebx
f0100934:	75 bb                	jne    f01008f1 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100936:	83 ec 08             	sub    $0x8,%esp
f0100939:	ff 75 a8             	pushl  -0x58(%ebp)
f010093c:	68 3f 1c 10 f0       	push   $0xf0101c3f
f0100941:	e8 49 00 00 00       	call   f010098f <cprintf>
f0100946:	83 c4 10             	add    $0x10,%esp
f0100949:	e9 f6 fe ff ff       	jmp    f0100844 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010094e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100951:	5b                   	pop    %ebx
f0100952:	5e                   	pop    %esi
f0100953:	5f                   	pop    %edi
f0100954:	5d                   	pop    %ebp
f0100955:	c3                   	ret    

f0100956 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100956:	55                   	push   %ebp
f0100957:	89 e5                	mov    %esp,%ebp
f0100959:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010095c:	ff 75 08             	pushl  0x8(%ebp)
f010095f:	e8 c6 fc ff ff       	call   f010062a <cputchar>
	*cnt++;
}
f0100964:	83 c4 10             	add    $0x10,%esp
f0100967:	c9                   	leave  
f0100968:	c3                   	ret    

f0100969 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100969:	55                   	push   %ebp
f010096a:	89 e5                	mov    %esp,%ebp
f010096c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010096f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100976:	ff 75 0c             	pushl  0xc(%ebp)
f0100979:	ff 75 08             	pushl  0x8(%ebp)
f010097c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010097f:	50                   	push   %eax
f0100980:	68 56 09 10 f0       	push   $0xf0100956
f0100985:	e8 52 04 00 00       	call   f0100ddc <vprintfmt>
	return cnt;
}
f010098a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010098d:	c9                   	leave  
f010098e:	c3                   	ret    

f010098f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010098f:	55                   	push   %ebp
f0100990:	89 e5                	mov    %esp,%ebp
f0100992:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100995:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100998:	50                   	push   %eax
f0100999:	ff 75 08             	pushl  0x8(%ebp)
f010099c:	e8 c8 ff ff ff       	call   f0100969 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009a1:	c9                   	leave  
f01009a2:	c3                   	ret    

f01009a3 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009a3:	55                   	push   %ebp
f01009a4:	89 e5                	mov    %esp,%ebp
f01009a6:	57                   	push   %edi
f01009a7:	56                   	push   %esi
f01009a8:	53                   	push   %ebx
f01009a9:	83 ec 14             	sub    $0x14,%esp
f01009ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009b5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009b8:	8b 1a                	mov    (%edx),%ebx
f01009ba:	8b 01                	mov    (%ecx),%eax
f01009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009bf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009c6:	eb 7f                	jmp    f0100a47 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009cb:	01 d8                	add    %ebx,%eax
f01009cd:	89 c6                	mov    %eax,%esi
f01009cf:	c1 ee 1f             	shr    $0x1f,%esi
f01009d2:	01 c6                	add    %eax,%esi
f01009d4:	d1 fe                	sar    %esi
f01009d6:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009d9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009dc:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009df:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009e1:	eb 03                	jmp    f01009e6 <stab_binsearch+0x43>
			m--;
f01009e3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009e6:	39 c3                	cmp    %eax,%ebx
f01009e8:	7f 0d                	jg     f01009f7 <stab_binsearch+0x54>
f01009ea:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009ee:	83 ea 0c             	sub    $0xc,%edx
f01009f1:	39 f9                	cmp    %edi,%ecx
f01009f3:	75 ee                	jne    f01009e3 <stab_binsearch+0x40>
f01009f5:	eb 05                	jmp    f01009fc <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009f7:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009fa:	eb 4b                	jmp    f0100a47 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009fc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009ff:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a02:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a06:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a09:	76 11                	jbe    f0100a1c <stab_binsearch+0x79>
			*region_left = m;
f0100a0b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a0e:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a10:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a13:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a1a:	eb 2b                	jmp    f0100a47 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a1c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a1f:	73 14                	jae    f0100a35 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a21:	83 e8 01             	sub    $0x1,%eax
f0100a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a27:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a2a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a2c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a33:	eb 12                	jmp    f0100a47 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a35:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a38:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a3a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a3e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a40:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a47:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a4a:	0f 8e 78 ff ff ff    	jle    f01009c8 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a50:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a54:	75 0f                	jne    f0100a65 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a59:	8b 00                	mov    (%eax),%eax
f0100a5b:	83 e8 01             	sub    $0x1,%eax
f0100a5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a61:	89 06                	mov    %eax,(%esi)
f0100a63:	eb 2c                	jmp    f0100a91 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a65:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a68:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a6a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a6d:	8b 0e                	mov    (%esi),%ecx
f0100a6f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a72:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a75:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a78:	eb 03                	jmp    f0100a7d <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a7a:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a7d:	39 c8                	cmp    %ecx,%eax
f0100a7f:	7e 0b                	jle    f0100a8c <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a81:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a85:	83 ea 0c             	sub    $0xc,%edx
f0100a88:	39 df                	cmp    %ebx,%edi
f0100a8a:	75 ee                	jne    f0100a7a <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a8c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a8f:	89 06                	mov    %eax,(%esi)
	}
}
f0100a91:	83 c4 14             	add    $0x14,%esp
f0100a94:	5b                   	pop    %ebx
f0100a95:	5e                   	pop    %esi
f0100a96:	5f                   	pop    %edi
f0100a97:	5d                   	pop    %ebp
f0100a98:	c3                   	ret    

f0100a99 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a99:	55                   	push   %ebp
f0100a9a:	89 e5                	mov    %esp,%ebp
f0100a9c:	57                   	push   %edi
f0100a9d:	56                   	push   %esi
f0100a9e:	53                   	push   %ebx
f0100a9f:	83 ec 3c             	sub    $0x3c,%esp
f0100aa2:	8b 75 08             	mov    0x8(%ebp),%esi
f0100aa5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100aa8:	c7 03 24 1e 10 f0    	movl   $0xf0101e24,(%ebx)
	info->eip_line = 0;
f0100aae:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ab5:	c7 43 08 24 1e 10 f0 	movl   $0xf0101e24,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100abc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ac3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ac6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100acd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ad3:	76 11                	jbe    f0100ae6 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad5:	b8 d1 73 10 f0       	mov    $0xf01073d1,%eax
f0100ada:	3d 61 5a 10 f0       	cmp    $0xf0105a61,%eax
f0100adf:	77 19                	ja     f0100afa <debuginfo_eip+0x61>
f0100ae1:	e9 aa 01 00 00       	jmp    f0100c90 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ae6:	83 ec 04             	sub    $0x4,%esp
f0100ae9:	68 2e 1e 10 f0       	push   $0xf0101e2e
f0100aee:	6a 7f                	push   $0x7f
f0100af0:	68 3b 1e 10 f0       	push   $0xf0101e3b
f0100af5:	e8 c9 f5 ff ff       	call   f01000c3 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100afa:	80 3d d0 73 10 f0 00 	cmpb   $0x0,0xf01073d0
f0100b01:	0f 85 90 01 00 00    	jne    f0100c97 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b0e:	b8 60 5a 10 f0       	mov    $0xf0105a60,%eax
f0100b13:	2d 70 20 10 f0       	sub    $0xf0102070,%eax
f0100b18:	c1 f8 02             	sar    $0x2,%eax
f0100b1b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b21:	83 e8 01             	sub    $0x1,%eax
f0100b24:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b27:	83 ec 08             	sub    $0x8,%esp
f0100b2a:	56                   	push   %esi
f0100b2b:	6a 64                	push   $0x64
f0100b2d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b30:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b33:	b8 70 20 10 f0       	mov    $0xf0102070,%eax
f0100b38:	e8 66 fe ff ff       	call   f01009a3 <stab_binsearch>
	if (lfile == 0)
f0100b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b40:	83 c4 10             	add    $0x10,%esp
f0100b43:	85 c0                	test   %eax,%eax
f0100b45:	0f 84 53 01 00 00    	je     f0100c9e <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b4b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b51:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b54:	83 ec 08             	sub    $0x8,%esp
f0100b57:	56                   	push   %esi
f0100b58:	6a 24                	push   $0x24
f0100b5a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b5d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b60:	b8 70 20 10 f0       	mov    $0xf0102070,%eax
f0100b65:	e8 39 fe ff ff       	call   f01009a3 <stab_binsearch>

	if (lfun <= rfun) {
f0100b6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b6d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b70:	83 c4 10             	add    $0x10,%esp
f0100b73:	39 d0                	cmp    %edx,%eax
f0100b75:	7f 40                	jg     f0100bb7 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b77:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b7a:	c1 e1 02             	shl    $0x2,%ecx
f0100b7d:	8d b9 70 20 10 f0    	lea    -0xfefdf90(%ecx),%edi
f0100b83:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b86:	8b b9 70 20 10 f0    	mov    -0xfefdf90(%ecx),%edi
f0100b8c:	b9 d1 73 10 f0       	mov    $0xf01073d1,%ecx
f0100b91:	81 e9 61 5a 10 f0    	sub    $0xf0105a61,%ecx
f0100b97:	39 cf                	cmp    %ecx,%edi
f0100b99:	73 09                	jae    f0100ba4 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b9b:	81 c7 61 5a 10 f0    	add    $0xf0105a61,%edi
f0100ba1:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ba4:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ba7:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100baa:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bad:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100baf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bb2:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bb5:	eb 0f                	jmp    f0100bc6 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bb7:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bbd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bc6:	83 ec 08             	sub    $0x8,%esp
f0100bc9:	6a 3a                	push   $0x3a
f0100bcb:	ff 73 08             	pushl  0x8(%ebx)
f0100bce:	e8 59 08 00 00       	call   f010142c <strfind>
f0100bd3:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bd6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bd9:	83 c4 08             	add    $0x8,%esp
f0100bdc:	56                   	push   %esi
f0100bdd:	6a 44                	push   $0x44
f0100bdf:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100be2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100be5:	b8 70 20 10 f0       	mov    $0xf0102070,%eax
f0100bea:	e8 b4 fd ff ff       	call   f01009a3 <stab_binsearch>
	if ( lline <= rline ){
f0100bef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100bf2:	83 c4 10             	add    $0x10,%esp
f0100bf5:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100bf8:	0f 8f a7 00 00 00    	jg     f0100ca5 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f0100bfe:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c01:	8d 04 85 70 20 10 f0 	lea    -0xfefdf90(,%eax,4),%eax
f0100c08:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c0c:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c0f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c12:	eb 06                	jmp    f0100c1a <debuginfo_eip+0x181>
f0100c14:	83 ea 01             	sub    $0x1,%edx
f0100c17:	83 e8 0c             	sub    $0xc,%eax
f0100c1a:	39 d6                	cmp    %edx,%esi
f0100c1c:	7f 34                	jg     f0100c52 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c1e:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c22:	80 f9 84             	cmp    $0x84,%cl
f0100c25:	74 0b                	je     f0100c32 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c27:	80 f9 64             	cmp    $0x64,%cl
f0100c2a:	75 e8                	jne    f0100c14 <debuginfo_eip+0x17b>
f0100c2c:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c30:	74 e2                	je     f0100c14 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c32:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c35:	8b 14 85 70 20 10 f0 	mov    -0xfefdf90(,%eax,4),%edx
f0100c3c:	b8 d1 73 10 f0       	mov    $0xf01073d1,%eax
f0100c41:	2d 61 5a 10 f0       	sub    $0xf0105a61,%eax
f0100c46:	39 c2                	cmp    %eax,%edx
f0100c48:	73 08                	jae    f0100c52 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c4a:	81 c2 61 5a 10 f0    	add    $0xf0105a61,%edx
f0100c50:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c52:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c55:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c58:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c5d:	39 f2                	cmp    %esi,%edx
f0100c5f:	7d 50                	jge    f0100cb1 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c61:	83 c2 01             	add    $0x1,%edx
f0100c64:	89 d0                	mov    %edx,%eax
f0100c66:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c69:	8d 14 95 70 20 10 f0 	lea    -0xfefdf90(,%edx,4),%edx
f0100c70:	eb 04                	jmp    f0100c76 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c72:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c76:	39 c6                	cmp    %eax,%esi
f0100c78:	7e 32                	jle    f0100cac <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c7a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c7e:	83 c0 01             	add    $0x1,%eax
f0100c81:	83 c2 0c             	add    $0xc,%edx
f0100c84:	80 f9 a0             	cmp    $0xa0,%cl
f0100c87:	74 e9                	je     f0100c72 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c8e:	eb 21                	jmp    f0100cb1 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c95:	eb 1a                	jmp    f0100cb1 <debuginfo_eip+0x218>
f0100c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c9c:	eb 13                	jmp    f0100cb1 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca3:	eb 0c                	jmp    f0100cb1 <debuginfo_eip+0x218>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if ( lline <= rline ){
		info->eip_line = stabs[lline].n_desc;
	}
	else{
		return -1;
f0100ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100caa:	eb 05                	jmp    f0100cb1 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cac:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cb4:	5b                   	pop    %ebx
f0100cb5:	5e                   	pop    %esi
f0100cb6:	5f                   	pop    %edi
f0100cb7:	5d                   	pop    %ebp
f0100cb8:	c3                   	ret    

f0100cb9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cb9:	55                   	push   %ebp
f0100cba:	89 e5                	mov    %esp,%ebp
f0100cbc:	57                   	push   %edi
f0100cbd:	56                   	push   %esi
f0100cbe:	53                   	push   %ebx
f0100cbf:	83 ec 1c             	sub    $0x1c,%esp
f0100cc2:	89 c7                	mov    %eax,%edi
f0100cc4:	89 d6                	mov    %edx,%esi
f0100cc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ccc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ccf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cda:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cdd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100ce0:	39 d3                	cmp    %edx,%ebx
f0100ce2:	72 05                	jb     f0100ce9 <printnum+0x30>
f0100ce4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ce7:	77 45                	ja     f0100d2e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ce9:	83 ec 0c             	sub    $0xc,%esp
f0100cec:	ff 75 18             	pushl  0x18(%ebp)
f0100cef:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cf2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100cf5:	53                   	push   %ebx
f0100cf6:	ff 75 10             	pushl  0x10(%ebp)
f0100cf9:	83 ec 08             	sub    $0x8,%esp
f0100cfc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cff:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d02:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d05:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d08:	e8 43 09 00 00       	call   f0101650 <__udivdi3>
f0100d0d:	83 c4 18             	add    $0x18,%esp
f0100d10:	52                   	push   %edx
f0100d11:	50                   	push   %eax
f0100d12:	89 f2                	mov    %esi,%edx
f0100d14:	89 f8                	mov    %edi,%eax
f0100d16:	e8 9e ff ff ff       	call   f0100cb9 <printnum>
f0100d1b:	83 c4 20             	add    $0x20,%esp
f0100d1e:	eb 18                	jmp    f0100d38 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d20:	83 ec 08             	sub    $0x8,%esp
f0100d23:	56                   	push   %esi
f0100d24:	ff 75 18             	pushl  0x18(%ebp)
f0100d27:	ff d7                	call   *%edi
f0100d29:	83 c4 10             	add    $0x10,%esp
f0100d2c:	eb 03                	jmp    f0100d31 <printnum+0x78>
f0100d2e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d31:	83 eb 01             	sub    $0x1,%ebx
f0100d34:	85 db                	test   %ebx,%ebx
f0100d36:	7f e8                	jg     f0100d20 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d38:	83 ec 08             	sub    $0x8,%esp
f0100d3b:	56                   	push   %esi
f0100d3c:	83 ec 04             	sub    $0x4,%esp
f0100d3f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d42:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d45:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d48:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d4b:	e8 30 0a 00 00       	call   f0101780 <__umoddi3>
f0100d50:	83 c4 14             	add    $0x14,%esp
f0100d53:	0f be 80 49 1e 10 f0 	movsbl -0xfefe1b7(%eax),%eax
f0100d5a:	50                   	push   %eax
f0100d5b:	ff d7                	call   *%edi
}
f0100d5d:	83 c4 10             	add    $0x10,%esp
f0100d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d63:	5b                   	pop    %ebx
f0100d64:	5e                   	pop    %esi
f0100d65:	5f                   	pop    %edi
f0100d66:	5d                   	pop    %ebp
f0100d67:	c3                   	ret    

f0100d68 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d6b:	83 fa 01             	cmp    $0x1,%edx
f0100d6e:	7e 0e                	jle    f0100d7e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d70:	8b 10                	mov    (%eax),%edx
f0100d72:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d75:	89 08                	mov    %ecx,(%eax)
f0100d77:	8b 02                	mov    (%edx),%eax
f0100d79:	8b 52 04             	mov    0x4(%edx),%edx
f0100d7c:	eb 22                	jmp    f0100da0 <getuint+0x38>
	else if (lflag)
f0100d7e:	85 d2                	test   %edx,%edx
f0100d80:	74 10                	je     f0100d92 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d82:	8b 10                	mov    (%eax),%edx
f0100d84:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d87:	89 08                	mov    %ecx,(%eax)
f0100d89:	8b 02                	mov    (%edx),%eax
f0100d8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d90:	eb 0e                	jmp    f0100da0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d92:	8b 10                	mov    (%eax),%edx
f0100d94:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d97:	89 08                	mov    %ecx,(%eax)
f0100d99:	8b 02                	mov    (%edx),%eax
f0100d9b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100da0:	5d                   	pop    %ebp
f0100da1:	c3                   	ret    

f0100da2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100da2:	55                   	push   %ebp
f0100da3:	89 e5                	mov    %esp,%ebp
f0100da5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100da8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dac:	8b 10                	mov    (%eax),%edx
f0100dae:	3b 50 04             	cmp    0x4(%eax),%edx
f0100db1:	73 0a                	jae    f0100dbd <sprintputch+0x1b>
		*b->buf++ = ch;
f0100db3:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100db6:	89 08                	mov    %ecx,(%eax)
f0100db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dbb:	88 02                	mov    %al,(%edx)
}
f0100dbd:	5d                   	pop    %ebp
f0100dbe:	c3                   	ret    

f0100dbf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100dbf:	55                   	push   %ebp
f0100dc0:	89 e5                	mov    %esp,%ebp
f0100dc2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dc5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dc8:	50                   	push   %eax
f0100dc9:	ff 75 10             	pushl  0x10(%ebp)
f0100dcc:	ff 75 0c             	pushl  0xc(%ebp)
f0100dcf:	ff 75 08             	pushl  0x8(%ebp)
f0100dd2:	e8 05 00 00 00       	call   f0100ddc <vprintfmt>
	va_end(ap);
}
f0100dd7:	83 c4 10             	add    $0x10,%esp
f0100dda:	c9                   	leave  
f0100ddb:	c3                   	ret    

f0100ddc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ddc:	55                   	push   %ebp
f0100ddd:	89 e5                	mov    %esp,%ebp
f0100ddf:	57                   	push   %edi
f0100de0:	56                   	push   %esi
f0100de1:	53                   	push   %ebx
f0100de2:	83 ec 2c             	sub    $0x2c,%esp
f0100de5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100de8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100deb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dee:	eb 12                	jmp    f0100e02 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100df0:	85 c0                	test   %eax,%eax
f0100df2:	0f 84 89 03 00 00    	je     f0101181 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100df8:	83 ec 08             	sub    $0x8,%esp
f0100dfb:	53                   	push   %ebx
f0100dfc:	50                   	push   %eax
f0100dfd:	ff d6                	call   *%esi
f0100dff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e02:	83 c7 01             	add    $0x1,%edi
f0100e05:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e09:	83 f8 25             	cmp    $0x25,%eax
f0100e0c:	75 e2                	jne    f0100df0 <vprintfmt+0x14>
f0100e0e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e12:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e19:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e20:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e27:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e2c:	eb 07                	jmp    f0100e35 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e31:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e35:	8d 47 01             	lea    0x1(%edi),%eax
f0100e38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e3b:	0f b6 07             	movzbl (%edi),%eax
f0100e3e:	0f b6 c8             	movzbl %al,%ecx
f0100e41:	83 e8 23             	sub    $0x23,%eax
f0100e44:	3c 55                	cmp    $0x55,%al
f0100e46:	0f 87 1a 03 00 00    	ja     f0101166 <vprintfmt+0x38a>
f0100e4c:	0f b6 c0             	movzbl %al,%eax
f0100e4f:	ff 24 85 e0 1e 10 f0 	jmp    *-0xfefe120(,%eax,4)
f0100e56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e59:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e5d:	eb d6                	jmp    f0100e35 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e62:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e6a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e6d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e71:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e74:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e77:	83 fa 09             	cmp    $0x9,%edx
f0100e7a:	77 39                	ja     f0100eb5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e7c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e7f:	eb e9                	jmp    f0100e6a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e81:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e84:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e87:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e8a:	8b 00                	mov    (%eax),%eax
f0100e8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e92:	eb 27                	jmp    f0100ebb <vprintfmt+0xdf>
f0100e94:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e97:	85 c0                	test   %eax,%eax
f0100e99:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e9e:	0f 49 c8             	cmovns %eax,%ecx
f0100ea1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ea4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ea7:	eb 8c                	jmp    f0100e35 <vprintfmt+0x59>
f0100ea9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100eac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100eb3:	eb 80                	jmp    f0100e35 <vprintfmt+0x59>
f0100eb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eb8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ebb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ebf:	0f 89 70 ff ff ff    	jns    f0100e35 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100ec5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ec8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ecb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ed2:	e9 5e ff ff ff       	jmp    f0100e35 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ed7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100edd:	e9 53 ff ff ff       	jmp    f0100e35 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ee2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ee5:	8d 50 04             	lea    0x4(%eax),%edx
f0100ee8:	89 55 14             	mov    %edx,0x14(%ebp)
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	53                   	push   %ebx
f0100eef:	ff 30                	pushl  (%eax)
f0100ef1:	ff d6                	call   *%esi
			break;
f0100ef3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ef6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ef9:	e9 04 ff ff ff       	jmp    f0100e02 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100efe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f01:	8d 50 04             	lea    0x4(%eax),%edx
f0100f04:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f07:	8b 00                	mov    (%eax),%eax
f0100f09:	99                   	cltd   
f0100f0a:	31 d0                	xor    %edx,%eax
f0100f0c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f0e:	83 f8 07             	cmp    $0x7,%eax
f0100f11:	7f 0b                	jg     f0100f1e <vprintfmt+0x142>
f0100f13:	8b 14 85 40 20 10 f0 	mov    -0xfefdfc0(,%eax,4),%edx
f0100f1a:	85 d2                	test   %edx,%edx
f0100f1c:	75 18                	jne    f0100f36 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f1e:	50                   	push   %eax
f0100f1f:	68 61 1e 10 f0       	push   $0xf0101e61
f0100f24:	53                   	push   %ebx
f0100f25:	56                   	push   %esi
f0100f26:	e8 94 fe ff ff       	call   f0100dbf <printfmt>
f0100f2b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f31:	e9 cc fe ff ff       	jmp    f0100e02 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f36:	52                   	push   %edx
f0100f37:	68 6a 1e 10 f0       	push   $0xf0101e6a
f0100f3c:	53                   	push   %ebx
f0100f3d:	56                   	push   %esi
f0100f3e:	e8 7c fe ff ff       	call   f0100dbf <printfmt>
f0100f43:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f49:	e9 b4 fe ff ff       	jmp    f0100e02 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f51:	8d 50 04             	lea    0x4(%eax),%edx
f0100f54:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f57:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f59:	85 ff                	test   %edi,%edi
f0100f5b:	b8 5a 1e 10 f0       	mov    $0xf0101e5a,%eax
f0100f60:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f67:	0f 8e 94 00 00 00    	jle    f0101001 <vprintfmt+0x225>
f0100f6d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f71:	0f 84 98 00 00 00    	je     f010100f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f77:	83 ec 08             	sub    $0x8,%esp
f0100f7a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f7d:	57                   	push   %edi
f0100f7e:	e8 5f 03 00 00       	call   f01012e2 <strnlen>
f0100f83:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f86:	29 c1                	sub    %eax,%ecx
f0100f88:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f8b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f8e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f95:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f98:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f9a:	eb 0f                	jmp    f0100fab <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f9c:	83 ec 08             	sub    $0x8,%esp
f0100f9f:	53                   	push   %ebx
f0100fa0:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fa3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fa5:	83 ef 01             	sub    $0x1,%edi
f0100fa8:	83 c4 10             	add    $0x10,%esp
f0100fab:	85 ff                	test   %edi,%edi
f0100fad:	7f ed                	jg     f0100f9c <vprintfmt+0x1c0>
f0100faf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fb2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fb5:	85 c9                	test   %ecx,%ecx
f0100fb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fbc:	0f 49 c1             	cmovns %ecx,%eax
f0100fbf:	29 c1                	sub    %eax,%ecx
f0100fc1:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fca:	89 cb                	mov    %ecx,%ebx
f0100fcc:	eb 4d                	jmp    f010101b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fd2:	74 1b                	je     f0100fef <vprintfmt+0x213>
f0100fd4:	0f be c0             	movsbl %al,%eax
f0100fd7:	83 e8 20             	sub    $0x20,%eax
f0100fda:	83 f8 5e             	cmp    $0x5e,%eax
f0100fdd:	76 10                	jbe    f0100fef <vprintfmt+0x213>
					putch('?', putdat);
f0100fdf:	83 ec 08             	sub    $0x8,%esp
f0100fe2:	ff 75 0c             	pushl  0xc(%ebp)
f0100fe5:	6a 3f                	push   $0x3f
f0100fe7:	ff 55 08             	call   *0x8(%ebp)
f0100fea:	83 c4 10             	add    $0x10,%esp
f0100fed:	eb 0d                	jmp    f0100ffc <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100fef:	83 ec 08             	sub    $0x8,%esp
f0100ff2:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff5:	52                   	push   %edx
f0100ff6:	ff 55 08             	call   *0x8(%ebp)
f0100ff9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ffc:	83 eb 01             	sub    $0x1,%ebx
f0100fff:	eb 1a                	jmp    f010101b <vprintfmt+0x23f>
f0101001:	89 75 08             	mov    %esi,0x8(%ebp)
f0101004:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101007:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010100a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010100d:	eb 0c                	jmp    f010101b <vprintfmt+0x23f>
f010100f:	89 75 08             	mov    %esi,0x8(%ebp)
f0101012:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101015:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101018:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010101b:	83 c7 01             	add    $0x1,%edi
f010101e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101022:	0f be d0             	movsbl %al,%edx
f0101025:	85 d2                	test   %edx,%edx
f0101027:	74 23                	je     f010104c <vprintfmt+0x270>
f0101029:	85 f6                	test   %esi,%esi
f010102b:	78 a1                	js     f0100fce <vprintfmt+0x1f2>
f010102d:	83 ee 01             	sub    $0x1,%esi
f0101030:	79 9c                	jns    f0100fce <vprintfmt+0x1f2>
f0101032:	89 df                	mov    %ebx,%edi
f0101034:	8b 75 08             	mov    0x8(%ebp),%esi
f0101037:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010103a:	eb 18                	jmp    f0101054 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010103c:	83 ec 08             	sub    $0x8,%esp
f010103f:	53                   	push   %ebx
f0101040:	6a 20                	push   $0x20
f0101042:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101044:	83 ef 01             	sub    $0x1,%edi
f0101047:	83 c4 10             	add    $0x10,%esp
f010104a:	eb 08                	jmp    f0101054 <vprintfmt+0x278>
f010104c:	89 df                	mov    %ebx,%edi
f010104e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101051:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101054:	85 ff                	test   %edi,%edi
f0101056:	7f e4                	jg     f010103c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101058:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010105b:	e9 a2 fd ff ff       	jmp    f0100e02 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101060:	83 fa 01             	cmp    $0x1,%edx
f0101063:	7e 16                	jle    f010107b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101065:	8b 45 14             	mov    0x14(%ebp),%eax
f0101068:	8d 50 08             	lea    0x8(%eax),%edx
f010106b:	89 55 14             	mov    %edx,0x14(%ebp)
f010106e:	8b 50 04             	mov    0x4(%eax),%edx
f0101071:	8b 00                	mov    (%eax),%eax
f0101073:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101076:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101079:	eb 32                	jmp    f01010ad <vprintfmt+0x2d1>
	else if (lflag)
f010107b:	85 d2                	test   %edx,%edx
f010107d:	74 18                	je     f0101097 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010107f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101082:	8d 50 04             	lea    0x4(%eax),%edx
f0101085:	89 55 14             	mov    %edx,0x14(%ebp)
f0101088:	8b 00                	mov    (%eax),%eax
f010108a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010108d:	89 c1                	mov    %eax,%ecx
f010108f:	c1 f9 1f             	sar    $0x1f,%ecx
f0101092:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101095:	eb 16                	jmp    f01010ad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101097:	8b 45 14             	mov    0x14(%ebp),%eax
f010109a:	8d 50 04             	lea    0x4(%eax),%edx
f010109d:	89 55 14             	mov    %edx,0x14(%ebp)
f01010a0:	8b 00                	mov    (%eax),%eax
f01010a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a5:	89 c1                	mov    %eax,%ecx
f01010a7:	c1 f9 1f             	sar    $0x1f,%ecx
f01010aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010bc:	79 74                	jns    f0101132 <vprintfmt+0x356>
				putch('-', putdat);
f01010be:	83 ec 08             	sub    $0x8,%esp
f01010c1:	53                   	push   %ebx
f01010c2:	6a 2d                	push   $0x2d
f01010c4:	ff d6                	call   *%esi
				num = -(long long) num;
f01010c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010cc:	f7 d8                	neg    %eax
f01010ce:	83 d2 00             	adc    $0x0,%edx
f01010d1:	f7 da                	neg    %edx
f01010d3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010db:	eb 55                	jmp    f0101132 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010dd:	8d 45 14             	lea    0x14(%ebp),%eax
f01010e0:	e8 83 fc ff ff       	call   f0100d68 <getuint>
			base = 10;
f01010e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010ea:	eb 46                	jmp    f0101132 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01010ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01010ef:	e8 74 fc ff ff       	call   f0100d68 <getuint>
			base = 8;
f01010f4:	b9 08 00 00 00       	mov    $0x8,%ecx
			//putch('\\',putdat);
			goto number;
f01010f9:	eb 37                	jmp    f0101132 <vprintfmt+0x356>
			//putch('X', putdat);
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01010fb:	83 ec 08             	sub    $0x8,%esp
f01010fe:	53                   	push   %ebx
f01010ff:	6a 30                	push   $0x30
f0101101:	ff d6                	call   *%esi
			putch('x', putdat);
f0101103:	83 c4 08             	add    $0x8,%esp
f0101106:	53                   	push   %ebx
f0101107:	6a 78                	push   $0x78
f0101109:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010110b:	8b 45 14             	mov    0x14(%ebp),%eax
f010110e:	8d 50 04             	lea    0x4(%eax),%edx
f0101111:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101114:	8b 00                	mov    (%eax),%eax
f0101116:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010111b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010111e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101123:	eb 0d                	jmp    f0101132 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101125:	8d 45 14             	lea    0x14(%ebp),%eax
f0101128:	e8 3b fc ff ff       	call   f0100d68 <getuint>
			base = 16;
f010112d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101132:	83 ec 0c             	sub    $0xc,%esp
f0101135:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101139:	57                   	push   %edi
f010113a:	ff 75 e0             	pushl  -0x20(%ebp)
f010113d:	51                   	push   %ecx
f010113e:	52                   	push   %edx
f010113f:	50                   	push   %eax
f0101140:	89 da                	mov    %ebx,%edx
f0101142:	89 f0                	mov    %esi,%eax
f0101144:	e8 70 fb ff ff       	call   f0100cb9 <printnum>
			break;
f0101149:	83 c4 20             	add    $0x20,%esp
f010114c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010114f:	e9 ae fc ff ff       	jmp    f0100e02 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101154:	83 ec 08             	sub    $0x8,%esp
f0101157:	53                   	push   %ebx
f0101158:	51                   	push   %ecx
f0101159:	ff d6                	call   *%esi
			break;
f010115b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010115e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101161:	e9 9c fc ff ff       	jmp    f0100e02 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101166:	83 ec 08             	sub    $0x8,%esp
f0101169:	53                   	push   %ebx
f010116a:	6a 25                	push   $0x25
f010116c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010116e:	83 c4 10             	add    $0x10,%esp
f0101171:	eb 03                	jmp    f0101176 <vprintfmt+0x39a>
f0101173:	83 ef 01             	sub    $0x1,%edi
f0101176:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010117a:	75 f7                	jne    f0101173 <vprintfmt+0x397>
f010117c:	e9 81 fc ff ff       	jmp    f0100e02 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101181:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101184:	5b                   	pop    %ebx
f0101185:	5e                   	pop    %esi
f0101186:	5f                   	pop    %edi
f0101187:	5d                   	pop    %ebp
f0101188:	c3                   	ret    

f0101189 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101189:	55                   	push   %ebp
f010118a:	89 e5                	mov    %esp,%ebp
f010118c:	83 ec 18             	sub    $0x18,%esp
f010118f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101192:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101195:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101198:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010119c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010119f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011a6:	85 c0                	test   %eax,%eax
f01011a8:	74 26                	je     f01011d0 <vsnprintf+0x47>
f01011aa:	85 d2                	test   %edx,%edx
f01011ac:	7e 22                	jle    f01011d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011ae:	ff 75 14             	pushl  0x14(%ebp)
f01011b1:	ff 75 10             	pushl  0x10(%ebp)
f01011b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011b7:	50                   	push   %eax
f01011b8:	68 a2 0d 10 f0       	push   $0xf0100da2
f01011bd:	e8 1a fc ff ff       	call   f0100ddc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011cb:	83 c4 10             	add    $0x10,%esp
f01011ce:	eb 05                	jmp    f01011d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011d5:	c9                   	leave  
f01011d6:	c3                   	ret    

f01011d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011d7:	55                   	push   %ebp
f01011d8:	89 e5                	mov    %esp,%ebp
f01011da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011e0:	50                   	push   %eax
f01011e1:	ff 75 10             	pushl  0x10(%ebp)
f01011e4:	ff 75 0c             	pushl  0xc(%ebp)
f01011e7:	ff 75 08             	pushl  0x8(%ebp)
f01011ea:	e8 9a ff ff ff       	call   f0101189 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011ef:	c9                   	leave  
f01011f0:	c3                   	ret    

f01011f1 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011f1:	55                   	push   %ebp
f01011f2:	89 e5                	mov    %esp,%ebp
f01011f4:	57                   	push   %edi
f01011f5:	56                   	push   %esi
f01011f6:	53                   	push   %ebx
f01011f7:	83 ec 0c             	sub    $0xc,%esp
f01011fa:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011fd:	85 c0                	test   %eax,%eax
f01011ff:	74 11                	je     f0101212 <readline+0x21>
		cprintf("%s", prompt);
f0101201:	83 ec 08             	sub    $0x8,%esp
f0101204:	50                   	push   %eax
f0101205:	68 6a 1e 10 f0       	push   $0xf0101e6a
f010120a:	e8 80 f7 ff ff       	call   f010098f <cprintf>
f010120f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101212:	83 ec 0c             	sub    $0xc,%esp
f0101215:	6a 00                	push   $0x0
f0101217:	e8 2f f4 ff ff       	call   f010064b <iscons>
f010121c:	89 c7                	mov    %eax,%edi
f010121e:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101221:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101226:	e8 0f f4 ff ff       	call   f010063a <getchar>
f010122b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010122d:	85 c0                	test   %eax,%eax
f010122f:	79 18                	jns    f0101249 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101231:	83 ec 08             	sub    $0x8,%esp
f0101234:	50                   	push   %eax
f0101235:	68 60 20 10 f0       	push   $0xf0102060
f010123a:	e8 50 f7 ff ff       	call   f010098f <cprintf>
			return NULL;
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	b8 00 00 00 00       	mov    $0x0,%eax
f0101247:	eb 79                	jmp    f01012c2 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101249:	83 f8 08             	cmp    $0x8,%eax
f010124c:	0f 94 c2             	sete   %dl
f010124f:	83 f8 7f             	cmp    $0x7f,%eax
f0101252:	0f 94 c0             	sete   %al
f0101255:	08 c2                	or     %al,%dl
f0101257:	74 1a                	je     f0101273 <readline+0x82>
f0101259:	85 f6                	test   %esi,%esi
f010125b:	7e 16                	jle    f0101273 <readline+0x82>
			if (echoing)
f010125d:	85 ff                	test   %edi,%edi
f010125f:	74 0d                	je     f010126e <readline+0x7d>
				cputchar('\b');
f0101261:	83 ec 0c             	sub    $0xc,%esp
f0101264:	6a 08                	push   $0x8
f0101266:	e8 bf f3 ff ff       	call   f010062a <cputchar>
f010126b:	83 c4 10             	add    $0x10,%esp
			i--;
f010126e:	83 ee 01             	sub    $0x1,%esi
f0101271:	eb b3                	jmp    f0101226 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101273:	83 fb 1f             	cmp    $0x1f,%ebx
f0101276:	7e 23                	jle    f010129b <readline+0xaa>
f0101278:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010127e:	7f 1b                	jg     f010129b <readline+0xaa>
			if (echoing)
f0101280:	85 ff                	test   %edi,%edi
f0101282:	74 0c                	je     f0101290 <readline+0x9f>
				cputchar(c);
f0101284:	83 ec 0c             	sub    $0xc,%esp
f0101287:	53                   	push   %ebx
f0101288:	e8 9d f3 ff ff       	call   f010062a <cputchar>
f010128d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101290:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101296:	8d 76 01             	lea    0x1(%esi),%esi
f0101299:	eb 8b                	jmp    f0101226 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010129b:	83 fb 0a             	cmp    $0xa,%ebx
f010129e:	74 05                	je     f01012a5 <readline+0xb4>
f01012a0:	83 fb 0d             	cmp    $0xd,%ebx
f01012a3:	75 81                	jne    f0101226 <readline+0x35>
			if (echoing)
f01012a5:	85 ff                	test   %edi,%edi
f01012a7:	74 0d                	je     f01012b6 <readline+0xc5>
				cputchar('\n');
f01012a9:	83 ec 0c             	sub    $0xc,%esp
f01012ac:	6a 0a                	push   $0xa
f01012ae:	e8 77 f3 ff ff       	call   f010062a <cputchar>
f01012b3:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012b6:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012bd:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c5:	5b                   	pop    %ebx
f01012c6:	5e                   	pop    %esi
f01012c7:	5f                   	pop    %edi
f01012c8:	5d                   	pop    %ebp
f01012c9:	c3                   	ret    

f01012ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012ca:	55                   	push   %ebp
f01012cb:	89 e5                	mov    %esp,%ebp
f01012cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d5:	eb 03                	jmp    f01012da <strlen+0x10>
		n++;
f01012d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012de:	75 f7                	jne    f01012d7 <strlen+0xd>
		n++;
	return n;
}
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01012f0:	eb 03                	jmp    f01012f5 <strnlen+0x13>
		n++;
f01012f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012f5:	39 c2                	cmp    %eax,%edx
f01012f7:	74 08                	je     f0101301 <strnlen+0x1f>
f01012f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012fd:	75 f3                	jne    f01012f2 <strnlen+0x10>
f01012ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101301:	5d                   	pop    %ebp
f0101302:	c3                   	ret    

f0101303 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101303:	55                   	push   %ebp
f0101304:	89 e5                	mov    %esp,%ebp
f0101306:	53                   	push   %ebx
f0101307:	8b 45 08             	mov    0x8(%ebp),%eax
f010130a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010130d:	89 c2                	mov    %eax,%edx
f010130f:	83 c2 01             	add    $0x1,%edx
f0101312:	83 c1 01             	add    $0x1,%ecx
f0101315:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101319:	88 5a ff             	mov    %bl,-0x1(%edx)
f010131c:	84 db                	test   %bl,%bl
f010131e:	75 ef                	jne    f010130f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101320:	5b                   	pop    %ebx
f0101321:	5d                   	pop    %ebp
f0101322:	c3                   	ret    

f0101323 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101323:	55                   	push   %ebp
f0101324:	89 e5                	mov    %esp,%ebp
f0101326:	53                   	push   %ebx
f0101327:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010132a:	53                   	push   %ebx
f010132b:	e8 9a ff ff ff       	call   f01012ca <strlen>
f0101330:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101333:	ff 75 0c             	pushl  0xc(%ebp)
f0101336:	01 d8                	add    %ebx,%eax
f0101338:	50                   	push   %eax
f0101339:	e8 c5 ff ff ff       	call   f0101303 <strcpy>
	return dst;
}
f010133e:	89 d8                	mov    %ebx,%eax
f0101340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101343:	c9                   	leave  
f0101344:	c3                   	ret    

f0101345 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101345:	55                   	push   %ebp
f0101346:	89 e5                	mov    %esp,%ebp
f0101348:	56                   	push   %esi
f0101349:	53                   	push   %ebx
f010134a:	8b 75 08             	mov    0x8(%ebp),%esi
f010134d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101350:	89 f3                	mov    %esi,%ebx
f0101352:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101355:	89 f2                	mov    %esi,%edx
f0101357:	eb 0f                	jmp    f0101368 <strncpy+0x23>
		*dst++ = *src;
f0101359:	83 c2 01             	add    $0x1,%edx
f010135c:	0f b6 01             	movzbl (%ecx),%eax
f010135f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101362:	80 39 01             	cmpb   $0x1,(%ecx)
f0101365:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101368:	39 da                	cmp    %ebx,%edx
f010136a:	75 ed                	jne    f0101359 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010136c:	89 f0                	mov    %esi,%eax
f010136e:	5b                   	pop    %ebx
f010136f:	5e                   	pop    %esi
f0101370:	5d                   	pop    %ebp
f0101371:	c3                   	ret    

f0101372 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101372:	55                   	push   %ebp
f0101373:	89 e5                	mov    %esp,%ebp
f0101375:	56                   	push   %esi
f0101376:	53                   	push   %ebx
f0101377:	8b 75 08             	mov    0x8(%ebp),%esi
f010137a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010137d:	8b 55 10             	mov    0x10(%ebp),%edx
f0101380:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101382:	85 d2                	test   %edx,%edx
f0101384:	74 21                	je     f01013a7 <strlcpy+0x35>
f0101386:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010138a:	89 f2                	mov    %esi,%edx
f010138c:	eb 09                	jmp    f0101397 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010138e:	83 c2 01             	add    $0x1,%edx
f0101391:	83 c1 01             	add    $0x1,%ecx
f0101394:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101397:	39 c2                	cmp    %eax,%edx
f0101399:	74 09                	je     f01013a4 <strlcpy+0x32>
f010139b:	0f b6 19             	movzbl (%ecx),%ebx
f010139e:	84 db                	test   %bl,%bl
f01013a0:	75 ec                	jne    f010138e <strlcpy+0x1c>
f01013a2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013a7:	29 f0                	sub    %esi,%eax
}
f01013a9:	5b                   	pop    %ebx
f01013aa:	5e                   	pop    %esi
f01013ab:	5d                   	pop    %ebp
f01013ac:	c3                   	ret    

f01013ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013ad:	55                   	push   %ebp
f01013ae:	89 e5                	mov    %esp,%ebp
f01013b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013b6:	eb 06                	jmp    f01013be <strcmp+0x11>
		p++, q++;
f01013b8:	83 c1 01             	add    $0x1,%ecx
f01013bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013be:	0f b6 01             	movzbl (%ecx),%eax
f01013c1:	84 c0                	test   %al,%al
f01013c3:	74 04                	je     f01013c9 <strcmp+0x1c>
f01013c5:	3a 02                	cmp    (%edx),%al
f01013c7:	74 ef                	je     f01013b8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013c9:	0f b6 c0             	movzbl %al,%eax
f01013cc:	0f b6 12             	movzbl (%edx),%edx
f01013cf:	29 d0                	sub    %edx,%eax
}
f01013d1:	5d                   	pop    %ebp
f01013d2:	c3                   	ret    

f01013d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013d3:	55                   	push   %ebp
f01013d4:	89 e5                	mov    %esp,%ebp
f01013d6:	53                   	push   %ebx
f01013d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013da:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013dd:	89 c3                	mov    %eax,%ebx
f01013df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013e2:	eb 06                	jmp    f01013ea <strncmp+0x17>
		n--, p++, q++;
f01013e4:	83 c0 01             	add    $0x1,%eax
f01013e7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013ea:	39 d8                	cmp    %ebx,%eax
f01013ec:	74 15                	je     f0101403 <strncmp+0x30>
f01013ee:	0f b6 08             	movzbl (%eax),%ecx
f01013f1:	84 c9                	test   %cl,%cl
f01013f3:	74 04                	je     f01013f9 <strncmp+0x26>
f01013f5:	3a 0a                	cmp    (%edx),%cl
f01013f7:	74 eb                	je     f01013e4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013f9:	0f b6 00             	movzbl (%eax),%eax
f01013fc:	0f b6 12             	movzbl (%edx),%edx
f01013ff:	29 d0                	sub    %edx,%eax
f0101401:	eb 05                	jmp    f0101408 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101403:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101408:	5b                   	pop    %ebx
f0101409:	5d                   	pop    %ebp
f010140a:	c3                   	ret    

f010140b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010140b:	55                   	push   %ebp
f010140c:	89 e5                	mov    %esp,%ebp
f010140e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101411:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101415:	eb 07                	jmp    f010141e <strchr+0x13>
		if (*s == c)
f0101417:	38 ca                	cmp    %cl,%dl
f0101419:	74 0f                	je     f010142a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010141b:	83 c0 01             	add    $0x1,%eax
f010141e:	0f b6 10             	movzbl (%eax),%edx
f0101421:	84 d2                	test   %dl,%dl
f0101423:	75 f2                	jne    f0101417 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101425:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010142a:	5d                   	pop    %ebp
f010142b:	c3                   	ret    

f010142c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010142c:	55                   	push   %ebp
f010142d:	89 e5                	mov    %esp,%ebp
f010142f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101432:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101436:	eb 03                	jmp    f010143b <strfind+0xf>
f0101438:	83 c0 01             	add    $0x1,%eax
f010143b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010143e:	38 ca                	cmp    %cl,%dl
f0101440:	74 04                	je     f0101446 <strfind+0x1a>
f0101442:	84 d2                	test   %dl,%dl
f0101444:	75 f2                	jne    f0101438 <strfind+0xc>
			break;
	return (char *) s;
}
f0101446:	5d                   	pop    %ebp
f0101447:	c3                   	ret    

f0101448 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101448:	55                   	push   %ebp
f0101449:	89 e5                	mov    %esp,%ebp
f010144b:	57                   	push   %edi
f010144c:	56                   	push   %esi
f010144d:	53                   	push   %ebx
f010144e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101451:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101454:	85 c9                	test   %ecx,%ecx
f0101456:	74 36                	je     f010148e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101458:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010145e:	75 28                	jne    f0101488 <memset+0x40>
f0101460:	f6 c1 03             	test   $0x3,%cl
f0101463:	75 23                	jne    f0101488 <memset+0x40>
		c &= 0xFF;
f0101465:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101469:	89 d3                	mov    %edx,%ebx
f010146b:	c1 e3 08             	shl    $0x8,%ebx
f010146e:	89 d6                	mov    %edx,%esi
f0101470:	c1 e6 18             	shl    $0x18,%esi
f0101473:	89 d0                	mov    %edx,%eax
f0101475:	c1 e0 10             	shl    $0x10,%eax
f0101478:	09 f0                	or     %esi,%eax
f010147a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010147c:	89 d8                	mov    %ebx,%eax
f010147e:	09 d0                	or     %edx,%eax
f0101480:	c1 e9 02             	shr    $0x2,%ecx
f0101483:	fc                   	cld    
f0101484:	f3 ab                	rep stos %eax,%es:(%edi)
f0101486:	eb 06                	jmp    f010148e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101488:	8b 45 0c             	mov    0xc(%ebp),%eax
f010148b:	fc                   	cld    
f010148c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010148e:	89 f8                	mov    %edi,%eax
f0101490:	5b                   	pop    %ebx
f0101491:	5e                   	pop    %esi
f0101492:	5f                   	pop    %edi
f0101493:	5d                   	pop    %ebp
f0101494:	c3                   	ret    

f0101495 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101495:	55                   	push   %ebp
f0101496:	89 e5                	mov    %esp,%ebp
f0101498:	57                   	push   %edi
f0101499:	56                   	push   %esi
f010149a:	8b 45 08             	mov    0x8(%ebp),%eax
f010149d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014a3:	39 c6                	cmp    %eax,%esi
f01014a5:	73 35                	jae    f01014dc <memmove+0x47>
f01014a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014aa:	39 d0                	cmp    %edx,%eax
f01014ac:	73 2e                	jae    f01014dc <memmove+0x47>
		s += n;
		d += n;
f01014ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014b1:	89 d6                	mov    %edx,%esi
f01014b3:	09 fe                	or     %edi,%esi
f01014b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014bb:	75 13                	jne    f01014d0 <memmove+0x3b>
f01014bd:	f6 c1 03             	test   $0x3,%cl
f01014c0:	75 0e                	jne    f01014d0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014c2:	83 ef 04             	sub    $0x4,%edi
f01014c5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014c8:	c1 e9 02             	shr    $0x2,%ecx
f01014cb:	fd                   	std    
f01014cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014ce:	eb 09                	jmp    f01014d9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014d0:	83 ef 01             	sub    $0x1,%edi
f01014d3:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014d6:	fd                   	std    
f01014d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014d9:	fc                   	cld    
f01014da:	eb 1d                	jmp    f01014f9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014dc:	89 f2                	mov    %esi,%edx
f01014de:	09 c2                	or     %eax,%edx
f01014e0:	f6 c2 03             	test   $0x3,%dl
f01014e3:	75 0f                	jne    f01014f4 <memmove+0x5f>
f01014e5:	f6 c1 03             	test   $0x3,%cl
f01014e8:	75 0a                	jne    f01014f4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014ea:	c1 e9 02             	shr    $0x2,%ecx
f01014ed:	89 c7                	mov    %eax,%edi
f01014ef:	fc                   	cld    
f01014f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014f2:	eb 05                	jmp    f01014f9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014f4:	89 c7                	mov    %eax,%edi
f01014f6:	fc                   	cld    
f01014f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014f9:	5e                   	pop    %esi
f01014fa:	5f                   	pop    %edi
f01014fb:	5d                   	pop    %ebp
f01014fc:	c3                   	ret    

f01014fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014fd:	55                   	push   %ebp
f01014fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101500:	ff 75 10             	pushl  0x10(%ebp)
f0101503:	ff 75 0c             	pushl  0xc(%ebp)
f0101506:	ff 75 08             	pushl  0x8(%ebp)
f0101509:	e8 87 ff ff ff       	call   f0101495 <memmove>
}
f010150e:	c9                   	leave  
f010150f:	c3                   	ret    

f0101510 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101510:	55                   	push   %ebp
f0101511:	89 e5                	mov    %esp,%ebp
f0101513:	56                   	push   %esi
f0101514:	53                   	push   %ebx
f0101515:	8b 45 08             	mov    0x8(%ebp),%eax
f0101518:	8b 55 0c             	mov    0xc(%ebp),%edx
f010151b:	89 c6                	mov    %eax,%esi
f010151d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101520:	eb 1a                	jmp    f010153c <memcmp+0x2c>
		if (*s1 != *s2)
f0101522:	0f b6 08             	movzbl (%eax),%ecx
f0101525:	0f b6 1a             	movzbl (%edx),%ebx
f0101528:	38 d9                	cmp    %bl,%cl
f010152a:	74 0a                	je     f0101536 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010152c:	0f b6 c1             	movzbl %cl,%eax
f010152f:	0f b6 db             	movzbl %bl,%ebx
f0101532:	29 d8                	sub    %ebx,%eax
f0101534:	eb 0f                	jmp    f0101545 <memcmp+0x35>
		s1++, s2++;
f0101536:	83 c0 01             	add    $0x1,%eax
f0101539:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010153c:	39 f0                	cmp    %esi,%eax
f010153e:	75 e2                	jne    f0101522 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101540:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101545:	5b                   	pop    %ebx
f0101546:	5e                   	pop    %esi
f0101547:	5d                   	pop    %ebp
f0101548:	c3                   	ret    

f0101549 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101549:	55                   	push   %ebp
f010154a:	89 e5                	mov    %esp,%ebp
f010154c:	53                   	push   %ebx
f010154d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101550:	89 c1                	mov    %eax,%ecx
f0101552:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101555:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101559:	eb 0a                	jmp    f0101565 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010155b:	0f b6 10             	movzbl (%eax),%edx
f010155e:	39 da                	cmp    %ebx,%edx
f0101560:	74 07                	je     f0101569 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101562:	83 c0 01             	add    $0x1,%eax
f0101565:	39 c8                	cmp    %ecx,%eax
f0101567:	72 f2                	jb     f010155b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101569:	5b                   	pop    %ebx
f010156a:	5d                   	pop    %ebp
f010156b:	c3                   	ret    

f010156c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010156c:	55                   	push   %ebp
f010156d:	89 e5                	mov    %esp,%ebp
f010156f:	57                   	push   %edi
f0101570:	56                   	push   %esi
f0101571:	53                   	push   %ebx
f0101572:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101575:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101578:	eb 03                	jmp    f010157d <strtol+0x11>
		s++;
f010157a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010157d:	0f b6 01             	movzbl (%ecx),%eax
f0101580:	3c 20                	cmp    $0x20,%al
f0101582:	74 f6                	je     f010157a <strtol+0xe>
f0101584:	3c 09                	cmp    $0x9,%al
f0101586:	74 f2                	je     f010157a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101588:	3c 2b                	cmp    $0x2b,%al
f010158a:	75 0a                	jne    f0101596 <strtol+0x2a>
		s++;
f010158c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010158f:	bf 00 00 00 00       	mov    $0x0,%edi
f0101594:	eb 11                	jmp    f01015a7 <strtol+0x3b>
f0101596:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010159b:	3c 2d                	cmp    $0x2d,%al
f010159d:	75 08                	jne    f01015a7 <strtol+0x3b>
		s++, neg = 1;
f010159f:	83 c1 01             	add    $0x1,%ecx
f01015a2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015a7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015ad:	75 15                	jne    f01015c4 <strtol+0x58>
f01015af:	80 39 30             	cmpb   $0x30,(%ecx)
f01015b2:	75 10                	jne    f01015c4 <strtol+0x58>
f01015b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015b8:	75 7c                	jne    f0101636 <strtol+0xca>
		s += 2, base = 16;
f01015ba:	83 c1 02             	add    $0x2,%ecx
f01015bd:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015c2:	eb 16                	jmp    f01015da <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015c4:	85 db                	test   %ebx,%ebx
f01015c6:	75 12                	jne    f01015da <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015cd:	80 39 30             	cmpb   $0x30,(%ecx)
f01015d0:	75 08                	jne    f01015da <strtol+0x6e>
		s++, base = 8;
f01015d2:	83 c1 01             	add    $0x1,%ecx
f01015d5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015da:	b8 00 00 00 00       	mov    $0x0,%eax
f01015df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015e2:	0f b6 11             	movzbl (%ecx),%edx
f01015e5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015e8:	89 f3                	mov    %esi,%ebx
f01015ea:	80 fb 09             	cmp    $0x9,%bl
f01015ed:	77 08                	ja     f01015f7 <strtol+0x8b>
			dig = *s - '0';
f01015ef:	0f be d2             	movsbl %dl,%edx
f01015f2:	83 ea 30             	sub    $0x30,%edx
f01015f5:	eb 22                	jmp    f0101619 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01015f7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015fa:	89 f3                	mov    %esi,%ebx
f01015fc:	80 fb 19             	cmp    $0x19,%bl
f01015ff:	77 08                	ja     f0101609 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101601:	0f be d2             	movsbl %dl,%edx
f0101604:	83 ea 57             	sub    $0x57,%edx
f0101607:	eb 10                	jmp    f0101619 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101609:	8d 72 bf             	lea    -0x41(%edx),%esi
f010160c:	89 f3                	mov    %esi,%ebx
f010160e:	80 fb 19             	cmp    $0x19,%bl
f0101611:	77 16                	ja     f0101629 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101613:	0f be d2             	movsbl %dl,%edx
f0101616:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101619:	3b 55 10             	cmp    0x10(%ebp),%edx
f010161c:	7d 0b                	jge    f0101629 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010161e:	83 c1 01             	add    $0x1,%ecx
f0101621:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101625:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101627:	eb b9                	jmp    f01015e2 <strtol+0x76>

	if (endptr)
f0101629:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010162d:	74 0d                	je     f010163c <strtol+0xd0>
		*endptr = (char *) s;
f010162f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101632:	89 0e                	mov    %ecx,(%esi)
f0101634:	eb 06                	jmp    f010163c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101636:	85 db                	test   %ebx,%ebx
f0101638:	74 98                	je     f01015d2 <strtol+0x66>
f010163a:	eb 9e                	jmp    f01015da <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010163c:	89 c2                	mov    %eax,%edx
f010163e:	f7 da                	neg    %edx
f0101640:	85 ff                	test   %edi,%edi
f0101642:	0f 45 c2             	cmovne %edx,%eax
}
f0101645:	5b                   	pop    %ebx
f0101646:	5e                   	pop    %esi
f0101647:	5f                   	pop    %edi
f0101648:	5d                   	pop    %ebp
f0101649:	c3                   	ret    
f010164a:	66 90                	xchg   %ax,%ax
f010164c:	66 90                	xchg   %ax,%ax
f010164e:	66 90                	xchg   %ax,%ax

f0101650 <__udivdi3>:
f0101650:	55                   	push   %ebp
f0101651:	57                   	push   %edi
f0101652:	56                   	push   %esi
f0101653:	53                   	push   %ebx
f0101654:	83 ec 1c             	sub    $0x1c,%esp
f0101657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010165b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010165f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101663:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101667:	85 f6                	test   %esi,%esi
f0101669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010166d:	89 ca                	mov    %ecx,%edx
f010166f:	89 f8                	mov    %edi,%eax
f0101671:	75 3d                	jne    f01016b0 <__udivdi3+0x60>
f0101673:	39 cf                	cmp    %ecx,%edi
f0101675:	0f 87 c5 00 00 00    	ja     f0101740 <__udivdi3+0xf0>
f010167b:	85 ff                	test   %edi,%edi
f010167d:	89 fd                	mov    %edi,%ebp
f010167f:	75 0b                	jne    f010168c <__udivdi3+0x3c>
f0101681:	b8 01 00 00 00       	mov    $0x1,%eax
f0101686:	31 d2                	xor    %edx,%edx
f0101688:	f7 f7                	div    %edi
f010168a:	89 c5                	mov    %eax,%ebp
f010168c:	89 c8                	mov    %ecx,%eax
f010168e:	31 d2                	xor    %edx,%edx
f0101690:	f7 f5                	div    %ebp
f0101692:	89 c1                	mov    %eax,%ecx
f0101694:	89 d8                	mov    %ebx,%eax
f0101696:	89 cf                	mov    %ecx,%edi
f0101698:	f7 f5                	div    %ebp
f010169a:	89 c3                	mov    %eax,%ebx
f010169c:	89 d8                	mov    %ebx,%eax
f010169e:	89 fa                	mov    %edi,%edx
f01016a0:	83 c4 1c             	add    $0x1c,%esp
f01016a3:	5b                   	pop    %ebx
f01016a4:	5e                   	pop    %esi
f01016a5:	5f                   	pop    %edi
f01016a6:	5d                   	pop    %ebp
f01016a7:	c3                   	ret    
f01016a8:	90                   	nop
f01016a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016b0:	39 ce                	cmp    %ecx,%esi
f01016b2:	77 74                	ja     f0101728 <__udivdi3+0xd8>
f01016b4:	0f bd fe             	bsr    %esi,%edi
f01016b7:	83 f7 1f             	xor    $0x1f,%edi
f01016ba:	0f 84 98 00 00 00    	je     f0101758 <__udivdi3+0x108>
f01016c0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016c5:	89 f9                	mov    %edi,%ecx
f01016c7:	89 c5                	mov    %eax,%ebp
f01016c9:	29 fb                	sub    %edi,%ebx
f01016cb:	d3 e6                	shl    %cl,%esi
f01016cd:	89 d9                	mov    %ebx,%ecx
f01016cf:	d3 ed                	shr    %cl,%ebp
f01016d1:	89 f9                	mov    %edi,%ecx
f01016d3:	d3 e0                	shl    %cl,%eax
f01016d5:	09 ee                	or     %ebp,%esi
f01016d7:	89 d9                	mov    %ebx,%ecx
f01016d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016dd:	89 d5                	mov    %edx,%ebp
f01016df:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016e3:	d3 ed                	shr    %cl,%ebp
f01016e5:	89 f9                	mov    %edi,%ecx
f01016e7:	d3 e2                	shl    %cl,%edx
f01016e9:	89 d9                	mov    %ebx,%ecx
f01016eb:	d3 e8                	shr    %cl,%eax
f01016ed:	09 c2                	or     %eax,%edx
f01016ef:	89 d0                	mov    %edx,%eax
f01016f1:	89 ea                	mov    %ebp,%edx
f01016f3:	f7 f6                	div    %esi
f01016f5:	89 d5                	mov    %edx,%ebp
f01016f7:	89 c3                	mov    %eax,%ebx
f01016f9:	f7 64 24 0c          	mull   0xc(%esp)
f01016fd:	39 d5                	cmp    %edx,%ebp
f01016ff:	72 10                	jb     f0101711 <__udivdi3+0xc1>
f0101701:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101705:	89 f9                	mov    %edi,%ecx
f0101707:	d3 e6                	shl    %cl,%esi
f0101709:	39 c6                	cmp    %eax,%esi
f010170b:	73 07                	jae    f0101714 <__udivdi3+0xc4>
f010170d:	39 d5                	cmp    %edx,%ebp
f010170f:	75 03                	jne    f0101714 <__udivdi3+0xc4>
f0101711:	83 eb 01             	sub    $0x1,%ebx
f0101714:	31 ff                	xor    %edi,%edi
f0101716:	89 d8                	mov    %ebx,%eax
f0101718:	89 fa                	mov    %edi,%edx
f010171a:	83 c4 1c             	add    $0x1c,%esp
f010171d:	5b                   	pop    %ebx
f010171e:	5e                   	pop    %esi
f010171f:	5f                   	pop    %edi
f0101720:	5d                   	pop    %ebp
f0101721:	c3                   	ret    
f0101722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101728:	31 ff                	xor    %edi,%edi
f010172a:	31 db                	xor    %ebx,%ebx
f010172c:	89 d8                	mov    %ebx,%eax
f010172e:	89 fa                	mov    %edi,%edx
f0101730:	83 c4 1c             	add    $0x1c,%esp
f0101733:	5b                   	pop    %ebx
f0101734:	5e                   	pop    %esi
f0101735:	5f                   	pop    %edi
f0101736:	5d                   	pop    %ebp
f0101737:	c3                   	ret    
f0101738:	90                   	nop
f0101739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101740:	89 d8                	mov    %ebx,%eax
f0101742:	f7 f7                	div    %edi
f0101744:	31 ff                	xor    %edi,%edi
f0101746:	89 c3                	mov    %eax,%ebx
f0101748:	89 d8                	mov    %ebx,%eax
f010174a:	89 fa                	mov    %edi,%edx
f010174c:	83 c4 1c             	add    $0x1c,%esp
f010174f:	5b                   	pop    %ebx
f0101750:	5e                   	pop    %esi
f0101751:	5f                   	pop    %edi
f0101752:	5d                   	pop    %ebp
f0101753:	c3                   	ret    
f0101754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101758:	39 ce                	cmp    %ecx,%esi
f010175a:	72 0c                	jb     f0101768 <__udivdi3+0x118>
f010175c:	31 db                	xor    %ebx,%ebx
f010175e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101762:	0f 87 34 ff ff ff    	ja     f010169c <__udivdi3+0x4c>
f0101768:	bb 01 00 00 00       	mov    $0x1,%ebx
f010176d:	e9 2a ff ff ff       	jmp    f010169c <__udivdi3+0x4c>
f0101772:	66 90                	xchg   %ax,%ax
f0101774:	66 90                	xchg   %ax,%ax
f0101776:	66 90                	xchg   %ax,%ax
f0101778:	66 90                	xchg   %ax,%ax
f010177a:	66 90                	xchg   %ax,%ax
f010177c:	66 90                	xchg   %ax,%ax
f010177e:	66 90                	xchg   %ax,%ax

f0101780 <__umoddi3>:
f0101780:	55                   	push   %ebp
f0101781:	57                   	push   %edi
f0101782:	56                   	push   %esi
f0101783:	53                   	push   %ebx
f0101784:	83 ec 1c             	sub    $0x1c,%esp
f0101787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010178b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010178f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101793:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101797:	85 d2                	test   %edx,%edx
f0101799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010179d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017a1:	89 f3                	mov    %esi,%ebx
f01017a3:	89 3c 24             	mov    %edi,(%esp)
f01017a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017aa:	75 1c                	jne    f01017c8 <__umoddi3+0x48>
f01017ac:	39 f7                	cmp    %esi,%edi
f01017ae:	76 50                	jbe    f0101800 <__umoddi3+0x80>
f01017b0:	89 c8                	mov    %ecx,%eax
f01017b2:	89 f2                	mov    %esi,%edx
f01017b4:	f7 f7                	div    %edi
f01017b6:	89 d0                	mov    %edx,%eax
f01017b8:	31 d2                	xor    %edx,%edx
f01017ba:	83 c4 1c             	add    $0x1c,%esp
f01017bd:	5b                   	pop    %ebx
f01017be:	5e                   	pop    %esi
f01017bf:	5f                   	pop    %edi
f01017c0:	5d                   	pop    %ebp
f01017c1:	c3                   	ret    
f01017c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017c8:	39 f2                	cmp    %esi,%edx
f01017ca:	89 d0                	mov    %edx,%eax
f01017cc:	77 52                	ja     f0101820 <__umoddi3+0xa0>
f01017ce:	0f bd ea             	bsr    %edx,%ebp
f01017d1:	83 f5 1f             	xor    $0x1f,%ebp
f01017d4:	75 5a                	jne    f0101830 <__umoddi3+0xb0>
f01017d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017da:	0f 82 e0 00 00 00    	jb     f01018c0 <__umoddi3+0x140>
f01017e0:	39 0c 24             	cmp    %ecx,(%esp)
f01017e3:	0f 86 d7 00 00 00    	jbe    f01018c0 <__umoddi3+0x140>
f01017e9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017ed:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017f1:	83 c4 1c             	add    $0x1c,%esp
f01017f4:	5b                   	pop    %ebx
f01017f5:	5e                   	pop    %esi
f01017f6:	5f                   	pop    %edi
f01017f7:	5d                   	pop    %ebp
f01017f8:	c3                   	ret    
f01017f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101800:	85 ff                	test   %edi,%edi
f0101802:	89 fd                	mov    %edi,%ebp
f0101804:	75 0b                	jne    f0101811 <__umoddi3+0x91>
f0101806:	b8 01 00 00 00       	mov    $0x1,%eax
f010180b:	31 d2                	xor    %edx,%edx
f010180d:	f7 f7                	div    %edi
f010180f:	89 c5                	mov    %eax,%ebp
f0101811:	89 f0                	mov    %esi,%eax
f0101813:	31 d2                	xor    %edx,%edx
f0101815:	f7 f5                	div    %ebp
f0101817:	89 c8                	mov    %ecx,%eax
f0101819:	f7 f5                	div    %ebp
f010181b:	89 d0                	mov    %edx,%eax
f010181d:	eb 99                	jmp    f01017b8 <__umoddi3+0x38>
f010181f:	90                   	nop
f0101820:	89 c8                	mov    %ecx,%eax
f0101822:	89 f2                	mov    %esi,%edx
f0101824:	83 c4 1c             	add    $0x1c,%esp
f0101827:	5b                   	pop    %ebx
f0101828:	5e                   	pop    %esi
f0101829:	5f                   	pop    %edi
f010182a:	5d                   	pop    %ebp
f010182b:	c3                   	ret    
f010182c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101830:	8b 34 24             	mov    (%esp),%esi
f0101833:	bf 20 00 00 00       	mov    $0x20,%edi
f0101838:	89 e9                	mov    %ebp,%ecx
f010183a:	29 ef                	sub    %ebp,%edi
f010183c:	d3 e0                	shl    %cl,%eax
f010183e:	89 f9                	mov    %edi,%ecx
f0101840:	89 f2                	mov    %esi,%edx
f0101842:	d3 ea                	shr    %cl,%edx
f0101844:	89 e9                	mov    %ebp,%ecx
f0101846:	09 c2                	or     %eax,%edx
f0101848:	89 d8                	mov    %ebx,%eax
f010184a:	89 14 24             	mov    %edx,(%esp)
f010184d:	89 f2                	mov    %esi,%edx
f010184f:	d3 e2                	shl    %cl,%edx
f0101851:	89 f9                	mov    %edi,%ecx
f0101853:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101857:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010185b:	d3 e8                	shr    %cl,%eax
f010185d:	89 e9                	mov    %ebp,%ecx
f010185f:	89 c6                	mov    %eax,%esi
f0101861:	d3 e3                	shl    %cl,%ebx
f0101863:	89 f9                	mov    %edi,%ecx
f0101865:	89 d0                	mov    %edx,%eax
f0101867:	d3 e8                	shr    %cl,%eax
f0101869:	89 e9                	mov    %ebp,%ecx
f010186b:	09 d8                	or     %ebx,%eax
f010186d:	89 d3                	mov    %edx,%ebx
f010186f:	89 f2                	mov    %esi,%edx
f0101871:	f7 34 24             	divl   (%esp)
f0101874:	89 d6                	mov    %edx,%esi
f0101876:	d3 e3                	shl    %cl,%ebx
f0101878:	f7 64 24 04          	mull   0x4(%esp)
f010187c:	39 d6                	cmp    %edx,%esi
f010187e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101882:	89 d1                	mov    %edx,%ecx
f0101884:	89 c3                	mov    %eax,%ebx
f0101886:	72 08                	jb     f0101890 <__umoddi3+0x110>
f0101888:	75 11                	jne    f010189b <__umoddi3+0x11b>
f010188a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010188e:	73 0b                	jae    f010189b <__umoddi3+0x11b>
f0101890:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101894:	1b 14 24             	sbb    (%esp),%edx
f0101897:	89 d1                	mov    %edx,%ecx
f0101899:	89 c3                	mov    %eax,%ebx
f010189b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010189f:	29 da                	sub    %ebx,%edx
f01018a1:	19 ce                	sbb    %ecx,%esi
f01018a3:	89 f9                	mov    %edi,%ecx
f01018a5:	89 f0                	mov    %esi,%eax
f01018a7:	d3 e0                	shl    %cl,%eax
f01018a9:	89 e9                	mov    %ebp,%ecx
f01018ab:	d3 ea                	shr    %cl,%edx
f01018ad:	89 e9                	mov    %ebp,%ecx
f01018af:	d3 ee                	shr    %cl,%esi
f01018b1:	09 d0                	or     %edx,%eax
f01018b3:	89 f2                	mov    %esi,%edx
f01018b5:	83 c4 1c             	add    $0x1c,%esp
f01018b8:	5b                   	pop    %ebx
f01018b9:	5e                   	pop    %esi
f01018ba:	5f                   	pop    %edi
f01018bb:	5d                   	pop    %ebp
f01018bc:	c3                   	ret    
f01018bd:	8d 76 00             	lea    0x0(%esi),%esi
f01018c0:	29 f9                	sub    %edi,%ecx
f01018c2:	19 d6                	sbb    %edx,%esi
f01018c4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018cc:	e9 18 ff ff ff       	jmp    f01017e9 <__umoddi3+0x69>
